#!/bin/ksh
############################################################
#       File:       prepoll.sh
#       Purpose:    Asynch Data prep
#
#       Version:
#       Parameters:
#       Created:
#       Author:   mbowen@mdcbowen.org
#       Parameters:
#       User to run with: essbase
#
#	modified 20030624.0900 by mbowen
#
############################################################
# Regional DW - Pre-Polling
#
#
# 20030320.1335 - mbowen@mdcbowen.org
# for Nissan USA
#
############################################################
#  The purpose of this prepoll is to find and categorize the
#  data to be processed. It will sort, classify, log and otherwise
#  prepare all data for all applications. It runs regularly
#  in order to have everything ready for the poll, which is
#  the big trigger for essbase updates.

#  It is called by watcher.sh independently of poll.sh
#
#
## this version to run on any box


## SUBS
log () {
	TIMESTAMP=`date '+%m/%d/%Y %H:%M:%S'`
	echo "${TIMESTAMP} ${PGMNAME} ${PID} $*" >>$logfile
}

notify() {
	TIMESTAMP=`date '+%H:%M:%S'`
	recipients='bowenm@nmc.nna, schwabj@nmc.nna, mcdougm@nmc.nna'
    mailx  -s "${envid} Prepoll Results" $recipients <<MEOF
    ${TIMESTAMP} Message: $*
MEOF
}

## INIT
# whereami
disk=`head -1 ~essbase/disk.dat`
envid=`head -1 ~essbase/env.dat`
typeset -L1 v=$envid

appid=$1

# some handy constants
PGMNAME=`basename $0`
PID=$$

# dates in various formats
TODAYHR=`date '+%y%m%d%H'`
TODAY=`date '+%y%m%d'`
THEDATE=`date '+%m/%d/%Y'`
DAYOFWEEK=`date '+%u'`

recipients='bowenm@nmc.nna'

# Modify for development

errdir="/${disk}03/essbase/rdwmr/errlogs/"
logdir="/${disk}03/essbase/rdwmr/logs/"
expdir="/${disk}03/essbase/rdwmr/export/"
appdir="/${disk}01/vendors/essbase/app/"
scrdir="/${disk}03/essbase/rdwmr/scripts/"
inpdir="/${disk}03/essbase/rdwmr/input/"


## app parse
## run types

## note that while 'appid' is used, these are etl streams which don't map app to app.
#  this case should be eliminated over time and each stream hardcoded wrt 'filetype'

case $appid in
	'rfin') xapp="RFIN"; db="Main"; fileType="ACT6"; valid=1;;
	'rbud') xapp="RFIN"; db="Main"; ext="6_b"; fileType="BUD6"; valid=1;;
	'elim') xapp="RFIN"; db="Main"; ext="_e"; fileType="ELIM"; valid=1;;
	'patb') xapp="PATB"; db="Main"; ext="_p"; fileType="PATB"; valid=1;;
	*)	valid=0;;
esac


## MAIN

logfile="${logdir}prepoll_activity.log"
rm -f ${scrdir}subvar.msh

rfin_companies="ana das ims nna nmac ncc ncfi nda nesci nmic nesco nmch nmex nmcic nmisc ntcna nmihc nca nci"
new=0
newb=0
subs=0
mex=0




## RUNTYPE 'B' (PATB)

if [[ $appid = 'patb' ]]; then

	## loop through all subs
	for company in $rfin_companies
	do
		# ACT6 files for PATB
		# use upper case for token name
		typeset -u big=$company
		tfile="${big}.token"
		dfile="${company}${ext}.txt"
		dfileT="${company}${ext}T.txt"

		if [[ -a ${inpdir}${appid}/$tfile ]]; then
			new=1
			log PATB ${big} ${fileType}  data found

			# copy into input file
			cp -p ${inpdir}${appid}/$dfile ${inpdir}

			# figure out the month from the token
			cd $scrdir
			bnum=`perl ${scrdir}tk.pl ${inpdir}${appid}/$tfile`

			# copy into date bucket directories (or bad-token)
			cp -p ${inpdir}${appid}/$dfile ${inpdir}${bnum}

			# supercat
			root="${company}${ext}"
			${scrdir}supercat.sh $root

			# now copy! the files
			cp -p ${inpdir}$dfile ${appdir}PATB/Main/$dfile


			# register each new run
			cd $scrdir
			cp -p ${inpdir}${appid}/$tfile .
			perl ${scrdir}reg.pl PATB ${big} ${fileType}
			rm -f $tfile

			# clean up
			cd ${inpdir}${appid}
			perl ${scrdir}zarc.pl $dfile
			perl ${scrdir}arc.pl $tfile

		fi

	done

	if [[ $new -eq 1 ]]; then
		touch ${inpdir}${appid}.token
		echo prepoll: new ${appid} data found.
	else
		echo prepoll: no new ${appid} data found
	fi


fi

## RFIN - look at *6.txt in rfin subdirctory (handles LOCL, RBS, RPLC, RPLU, RX11, RX10)

if [[ $appid = 'rfin' ]]; then

	## loop through all subs
	for company in $rfin_companies
	do
		#ACT6, ACT9 files for all companies are on this token
		# we will create the split subsets for RPL & RBS
		# we will also allow RFIN to work in all this.

		# use upper case for token name
		typeset -u big=$company
		tfile="${big}.token"
		file6="${company}6.txt"
		file6p="${company}6p.txt"
		file6T="${company}6T.txt"
		file6pT="${company}6pT.txt"
		file9="${company}9.txt"
		file9T="${company}9T.txt"

		if [[ -a ${inpdir}rfin/$tfile ]]; then
			new=1
			log RFIN $big $fileType data found

			# copy into input directory
			cp -p ${inpdir}rfin/$file6 ${inpdir}
			cp -p ${inpdir}rfin/$file9 ${inpdir}

			# figure out the month from the token
			cd $scrdir
			bnum=`perl ${scrdir}tk.pl ${inpdir}rfin/$tfile`

			# copy into date bucket directories
			cp -p ${inpdir}rfin/$file6 ${inpdir}${bnum}
			cp -p ${inpdir}rfin/$file9 ${inpdir}${bnum}

			# split the  6-file into 6p (p&l accounts only)
			cd $scrdir
			cp -p ${inpdir}$file6 .
			perl ${scrdir}sp.pl ${file6} ${inpdir}${file6p}
			rm -f $file6

			# mock send them to rps, rpl
			cp -p ${inpdir}${file6} ${inpdir}rbs
			cp -p ${inpdir}${file6p} ${inpdir}rpl
			cp -p ${inpdir}${file6p} ${inpdir}${bnum} #date bucket for this too

			# supercat
			root6="${company}6"
			root9="${company}9"
			${scrdir}supercat.sh $root6
			${scrdir}supercat.sh $root9


			# now copy the files up to Essbase
			cp -p ${inpdir}$file6p ${appdir}RPLU/Main/$file6p
			cp -p ${inpdir}$file6p ${appdir}RPLA/Main/$file6p
			cp -p ${inpdir}$file6p ${appdir}RPLB/Main/$file6p
			cp -p ${inpdir}$file6 ${appdir}RBS/Main/$file6
			cp -p ${inpdir}$file9 ${appdir}LOCL/Main/$file9


			# register each new run
			cd $scrdir
			cp -p ${inpdir}rfin/$tfile .
			perl ${scrdir}reg.pl RFIN ${big} ACT6P
			perl ${scrdir}reg.pl RFIN ${big} ACT6
			perl ${scrdir}reg.pl RFIN ${big} ACT9
			rm -f $tfile

			# clean up
			cd ${inpdir}rfin
			perl ${scrdir}zarc.pl $file6
			perl ${scrdir}zarc.pl $file6p
			perl ${scrdir}zarc.pl $file9
			perl ${scrdir}arc.pl $tfile

		fi

	done

	if [[ $new -eq 1 ]]; then
		touch ${inpdir}rpla.token
		touch ${inpdir}rplu.token
		touch ${inpdir}rbs.token
		touch ${inpdir}rplb.token
		touch ${inpdir}locl.token
		echo prepoll: new rfin data found.



	else
		echo prepoll: no new rfin data found


	fi



fi



### RBUD - look at *6_b.txt in rbud subdirctory
# we will rename the _eb to the _b and deal only with the _b the type 0 will not be archived
if [[ $appid = 'rbud' ]]; then

	## loop through all subs
	for company in $rfin_companies
	do
		# use upper case for token name
		typeset -u big=$company
		tfile="${big}.token"
		file6p="${company}6p_b.txt"
		file6="${company}6_b.txt"
		file6e="${company}6_eb.txt"
		file9="${company}9_b.txt"

		if [[ -a ${inpdir}rbud/$tfile ]]; then
			new=1
			log RFIN $big $fileType data found
			#notify RFIN $big $fileType data found

			# overwrite the type 0 with the type 1
			mv ${inpdir}rbud/${file6e} ${inpdir}rbud/${file6}

			# copy into input directory
			cp -p ${inpdir}rbud/$file6 ${inpdir}
			cp -p ${inpdir}rbud/$file9 ${inpdir}

			# figure out the month from the token
			# bnum=`head -1 ${inpdir}rbud/$tfile`

			# copy into date bucket directories
			cp -p ${inpdir}rbud/$file6 ${inpdir}budgets
			cp -p ${inpdir}rbud/$file9 ${inpdir}budgets

			# split the  6-file into 6p and 6b versions
			cd $scrdir
			cp -p ${inpdir}$file6 .
			perl ${scrdir}sp.pl ${file6} ${inpdir}${file6p}
			rm -f $file6

			# mock send them to rps, rpl
			cp -p ${inpdir}${file6} ${inpdir}rbs
			cp -p ${inpdir}${file6p} ${inpdir}rpl
			cp -p ${inpdir}${file6p} ${inpdir}budgets

			# supercat
			# no need to concatenate - budgets are one full year

			# now copy the files up to Essbase
			cp -p ${inpdir}$file6 ${appdir}RBS/Main/$file6
			cp -p ${inpdir}$file6p ${appdir}RPLA/Main/$file6p
			cp -p ${inpdir}$file6p ${appdir}RPLB/Main/$file6p
			cp -p ${inpdir}$file6p ${appdir}RPLU/Main/$file6p
			cp -p ${inpdir}$file9 ${appdir}LOCL/Main/$file9

			# register each new run
			cd $scrdir
			cp -p ${inpdir}rbud/$tfile .
			perl ${scrdir}reg.pl RBUD ${big} BUD6
			perl ${scrdir}reg.pl RBUD ${big} BUD6P
			perl ${scrdir}reg.pl RBUD ${big} BUD9
			rm -f $tfile

			# clean up
			cd ${inpdir}rbud
			perl ${scrdir}zarc.pl $file6
			perl ${scrdir}zarc.pl $file6p
			perl ${scrdir}zarc.pl $file9
			perl ${scrdir}arc.pl $tfile


		fi


	done

	## Elimination Budget

	tfile="ALL.token"
	efile="all_eb.txt"
	efilep="allp_eb.txt"


	if [[ -a ${inpdir}rbud/$tfile ]]; then
		new=1
		log RFIN $big $fileType data found
		#notify RFIN $big $fileType data found

		# copy into input directory
		cp -p ${inpdir}rbud/$efile ${inpdir}

		# copy into date bucket directories
		cp -p ${inpdir}rbud/$efile ${inpdir}budgets

		# split the file into p version
		cd $scrdir
		cp -p ${inpdir}$efile .
		perl ${scrdir}sp.pl ${efile} ${inpdir}${efilep}
		rm -f $efile

		# mock send them to rps, rpl
		cp -p ${inpdir}${efile} ${inpdir}rbs
		cp -p ${inpdir}${efilep} ${inpdir}rpl
		cp -p ${inpdir}${efilep} ${inpdir}budgets

		# supercat
		# no need to concatenate - budgets are one full year

		# now copy the files up to Essbase
		cp -p ${inpdir}$efile ${appdir}RBS/Main/$efile
		cp -p ${inpdir}$efilep ${appdir}RPLA/Main/$efilep
		cp -p ${inpdir}$efilep ${appdir}RPLB/Main/$efilep

		# register each new run
		cd $scrdir
		cp -p ${inpdir}rbud/$tfile .
		perl ${scrdir}reg.pl RBUD ALL ELIMB
		perl ${scrdir}reg.pl RBUD ALL ELIMBP
		rm -f $tfile

		# clean up
		cd ${inpdir}rbud
		perl ${scrdir}zarc.pl $efile
		perl ${scrdir}zarc.pl $efilep
		perl ${scrdir}arc.pl $tfile


	fi



	if [[ $new -eq 1 ]]; then
		touch ${inpdir}rpla.token
		touch ${inpdir}rplb.token
		touch ${inpdir}rbs.token
		touch ${inpdir}locl.token
		echo prepoll: new rfin budget data found.

	else
		echo prepoll: no new rfin budget data found


	fi


fi

### STAT code removed - 20030601 - mbowen


## ELIM - look at all_e.txt in elim subdirctory - a single file not by company

if [[ $appid = 'elim' ]]; then

	# eliminations are only and always 6 digits

	# use upper case for token name
	typeset -u big=$company
	tfile="ALL.token"
	dfile="all_e.txt"
	dfile6p="allp_e.txt"
	dfileT="all_eT.txt"
	file6pT="allp_eT.txt"

	if [[ -a ${inpdir}elim/$tfile ]]; then
		new=1
		log ELIM ALL $fileType data found

		# copy into input directory
		echo copy to input from elim
		cp -p ${inpdir}elim/${dfile} ${inpdir}


		# figure out the month from the token
		# bnum=`head -1 ${inpdir}elim/$tfile`
		echo interpret token
		cd $scrdir
		bnum=`perl ${scrdir}tk.pl ${inpdir}elim/$tfile`

		# copy into date bucket directories
		echo copy into $bnum
		cp -p ${inpdir}elim/$dfile ${inpdir}${bnum}

		# split the  6-file into 6p versions
		echo split
		cd $scrdir
		cp -p ${inpdir}$dfile .
		perl ${scrdir}sp.pl ${dfile} ${inpdir}${dfile6p}
		rm -f $dfile


		# supercat
		echo supercat
		root="all_e"
		${scrdir}supercat.sh $root
		root="allp_e"
		${scrdir}supercat.sh $root

		# send them to rps, rpl, rfem, date bucket
		echo mock copies - three
		cp -p ${inpdir}${dfile} ${inpdir}rfem
		cp -p ${inpdir}${dfile} ${inpdir}rbs
		cp -p ${inpdir}${dfile6p} ${inpdir}rpl
		cp -p ${inpdir}${dfile6p} ${inpdir}${bnum}

		# now copy the files up to Essbase
		echo app copies - three
		cp -p ${inpdir}$dfile ${appdir}RBS/Main/$dfile
		cp -p ${inpdir}$dfile6p ${appdir}RPLA/Main/$dfile6p
		cp -p ${inpdir}$dfile6p ${appdir}RPLB/Main/$dfile6p
		cp -p ${inpdir}$dfile ${appdir}RFEM/Main/$dfile


		# register each new run
		echo registry
		cd $scrdir
		cp -p ${inpdir}elim/$tfile .
		perl ${scrdir}reg.pl ELIM ALL ELIM
		perl ${scrdir}reg.pl ELIM ALL ELIMP
		rm -f $tfile

		# clean up
		echo cleanup
		cd ${inpdir}elim
		perl ${scrdir}zarc.pl $dfile
		perl ${scrdir}arc.pl $tfile


	fi


	if [[ $new -eq 1 ]]; then
		echo touch
		touch ${inpdir}rpla.token
		touch ${inpdir}rplb.token
		touch ${inpdir}rbs.token
		touch ${inpdir}rfem.token
		echo prepoll: new elim data found.


	else
		echo prepoll: no new elim data found


	fi


fi





## -- old code --

# if [[ $newb -eq 1 || $new -eq 1 ]]; then
#	cat ${logdir}prepoll_activity.log |grep ${THEDATE}| mailx -s "${envid} RFIN/RBUD Prepoll Results" $recipients
# fi


######

### check for new posting date
##if [[ ! -a ${inpdir}subvar.msh ]]; then
##
##	# the perl script will parse the token file (first parm)
##	# and then conditionally create subvar.msh
##	perl ${scrdir}subvar.pl ${inpdir}rfin/$tfile
##fi


# force a date into the tfile
#cd ${scrdir}
# perl ${scrdir}ft.pl ${inpdir}rbud/$file6 rbud
#head -1 ${inpdir}rbud/$file6 > temp.txt
#dt=`cut -f2 -d\| temp.txt`
#echo prepoll: force $dt - token not overwritten


# check to see if it's mexico
#if [[ $company = 'nmex' ]]; then
#	mex=1
#	cp -p ${inpdir}rfin/$file6 ${inpdir}mex6
#	cp -p ${inpdir}rfin/$tfile ${inpdir}mex6
#	touch ${inpdir}mex6.token
#	echo prepoll: new mex6 data found.
#fi

#### STAT - look at *6_b.txt in rfin subdirctory
#
#if [[ $appid = 'stat' ]]; then
#
#	## loop through all subs -
#	#  stats always go to rpl -
#	#  stats are only and always 6 digit
#	for company in $rfin_companies
#	do
#		# use upper case for token name
#		typeset -u big=$company
#		tfile="${big}.token"
#		dfile="${company}_s.txt"
#		dfileT="${company}_sT.txt"
#
#
#		if [[ -a ${inpdir}stat/$tfile ]]; then
#			new=1
#			log RFIN $big $fileType data found
#			# notify RFIN $big $fileType data found
#
#
#			# copy into input directory
#			cp -p ${inpdir}stat/$dfile ${inpdir}
#
#			# figure out the month from the token
#			# bnum=`head -1 ${inpdir}stat/$tfile`
#			cd $scrdir
#			bnum=`perl ${scrdir}tk.pl ${inpdir}stat/$tfile`
#
#			# copy into date bucket directories
#			cp -p ${inpdir}stat/$dfile ${inpdir}${bnum}
#
#			# supercat
#			root="${company}_s"
#			${scrdir}supercat.sh $root
#
#			# now copy the files up to Essbase
#			cp -p ${inpdir}$dfile ${appdir}RPL/Main/$dfile
#			#cp -p ${inpdir}$dfile ${appdir}RFIN/Main/$dfile
#
#			cp -p ${inpdir}totals/$dfileT ${appdir}RPL/Main/$dfileT
#			#cp -p ${inpdir}totals/$dfileT ${appdir}RFIN/Main/$dfileT
#
#			# register each new run
#			cd $scrdir
#			cp -p ${inpdir}stat/$tfile .
#			#perl ${scrdir}reg.pl RFIN ${big} ${fileType}
#			perl ${scrdir}reg.pl RPL ${big} STAT
#			rm -f $tfile
#
#			# clean up
#			cd ${inpdir}stat
#			perl ${scrdir}zarc.pl $dfile
#			perl ${scrdir}arc.pl $tfile
#
#
#		fi
#
#
#	done
#
#	if [[ $new -eq 1 ]]; then
#		touch ${inpdir}rpl.token
#		# touch ${inpdir}rfin.token
#		echo prepoll: new statistical data found.
#
#	else
#		echo prepoll: no new stat data found
#
#
#	fi
#
#
#fi


# paic code removed. 20030603 - mbowen@mdcbowen.org
# rx11, rx10 added 20030624
# totals subdirectory added to rfin stream update (that crazy error)


### old code
## removed supercatted data from automatically copying in the rfin pass - let duperT do it.

#			cp -p ${inpdir}totals/$file6pT ${appdir}RPLU/Main/$file6pT
#			cp -p ${inpdir}totals/$file6pT ${appdir}RPLC/Main/$file6pT
#			cp -p ${inpdir}totals/$file6pT ${appdir}RX10/Main/$file6pT
#			cp -p ${inpdir}totals/$file6pT ${appdir}RX11/Main/$file6pT
#			cp -p ${inpdir}totals/$file6T ${appdir}RBS/Main/$file6T
#			cp -p ${inpdir}totals/$file6T ${appdir}RBSC/Main/$file6T
#			cp -p ${inpdir}totals/$file9T ${appdir}LOCL/Main/$file9T
