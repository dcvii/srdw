#!/bin/ksh
############################################################
#       File:       update.sh
#       Purpose:    Auto Feed to Essbase
#
#       Version:
#       Parameters:
#       Created:
#       Author:   mbowen@mdcbowen.org
#       Parameters:
#       User to run with: essbase
#
#	modified 20030415.0930 by mbowen
#
############################################################

## this version should run on any box

appid=$1
# whereami
disk=`head -1 ~essbase/disk.dat`
envid=`head -1 ~essbase/env.dat`


errdir="/${disk}03/essbase/rdwmr/errlogs/"
logdir="/${disk}03/essbase/rdwmr/logs/"
expdir="/${disk}03/essbase/rdwmr/export/"
appdir="/${disk}01/vendors/essbase/app/"
scrdir="/${disk}03/essbase/rdwmr/scripts/"
inpdir="/${disk}03/essbase/rdwmr/input/"
bindir="/${disk}01/vendors/essbase/bin/"


rfin_companies="ana das ims nna nmac ncc ncfi nda nesci nmic nesco nmch nmex nmcic nmisc ntcna nmihc nca nci"
recipients='bowenm@nmc.nna, schwabj@nmc.nna, mcdougm@nmc.nna'

logfile="${logdir}update_activity.log"
today=`date '+%m%d'`


## subs
log () {
	TIMESTAMP=`date '+%m/%d/%Y %H:%M:%S'`
	echo "${TIMESTAMP} ${PGMNAME} ${PID} $*" >>$logfile
}


## app parse
case $appid in
	'rfem') errType="B"; xapp="RFEM"; db="Main";  valid=1;;
	'locl') errType="B"; xapp="LOCL"; db="Main";  valid=1;;
	'rbs') errType="B"; xapp="RBS"; db="Main";  valid=1;;
	'rpla') apptype="rpl"; xapp="RPLA"; db="Main";  valid=1;;
	'rplb') apptype="rpl"; xapp="RPLB"; db="Main";  valid=1;;
	'rplu') apptype="rpl"; xapp="RPLU"; db="Main";  valid=1;;
	'patb') errType="B"; xapp="PATB"; db="Main";  valid=1;;
	*)	valid=0;;
esac

## UPDATE SECTION ## --------------------------------------------------------

if [[ valid -eq 1 ]]; then

	echo update.sh: updating ${xapp}..
	log updating ${xapp}..

	## RUN SPECIFIC UPDATE MSH
	cd $scrdir

	${bindir}essmsh ${appid}_update.msh > ${logdir}${appid}_update.log
	# ${scrdir}stats.sh $appid >> ${logdir}${appid}_update.log

	## NOTIFY OF THE UPDATE
	cd ${logdir}
	cat ${appid}_update.log | mailx -s "$envid $xapp Update Results" $recipients
	perl ${scrdir}arc.pl ${appid}_update.log

else

	echo invalid selection for update.sh of $appid
	log invalid selection for update.sh of $appid


fi


## NOTIFICATION SECTION ##-----------------------------------------------------

## RFEM
if [[ $appid = 'rfem' ]]; then

	cd ${errdir}
	et=0
	efile=${appdir}RFEM/Main/err${today}.txt
	echo '\\\\' $efile > $efile
	# data load rejects only
	## loop through all subs

	rfile="${appid}_all_l_elim.err"
	# example: rfem_all_l_elim.err


	if [[ -a $rfile ]]; then
		et=1
		log $rfile data rejects found
		cat $rfile >> $efile
		perl ${scrdir}uerr.pl $rfile
		cat $rfile.u | mailx -s "$envid ${xapp} Data Load Rejects" $recipients
		perl ${scrdir}zarc.pl $rfile
		perl ${scrdir}arc.pl ${rfile}.u
	fi


	if [[ $et -eq 1 ]]; then
		touch ${inpdir}rfem.error.token
	fi


fi



## LOCL
if [[ $appid = 'locl' ]]; then

	cd ${errdir}
	et=0
	efile=${appdir}LOCL/Main/err${today}.txt
	echo '\\\\' $efile > $efile
	# data load rejects only
	## loop through all subs
	for company in $rfin_companies
	do

		rfile="${appid}_${company}_l_data.err"
		# example: locl_nmcic_l_data.err


		if [[ -a $rfile ]]; then
			et=1
			log $rfile data rejects found
			cat $rfile >> $efile
			perl ${scrdir}uerr.pl $rfile
			cat $rfile.u | mailx -s "$envid ${xapp} $company Data Load Rejects" $recipients
			perl ${scrdir}zarc.pl $rfile
			perl ${scrdir}arc.pl ${rfile}.u
		fi

		# budgets
		rfile="${appid}_${company}_l_bud.err"
		# example: locl_nmcic_l_bud.err


		if [[ -a $rfile ]]; then
			et=1
			cat $rfile >> $efile
			log $rfile data rejects found
			perl ${scrdir}uerr.pl $rfile
			cat $rfile.u | mailx -s "$envid ${xapp} $company Data Load Rejects" $recipients
			perl ${scrdir}zarc.pl $rfile
			perl ${scrdir}arc.pl ${rfile}.u
		fi


	done
	if [[ $et -eq 1 ]]; then
		touch ${inpdir}locl.error.token
	fi


fi



## PATB
if [[ $appid = 'patb' ]]; then

	cd ${errdir}
	et=0
	efile=${appdir}PATB/Main/err${today}.txt
	echo '\\\\' $efile > $efile
	# data load rejects only
	## loop through all subs
	for company in $rfin_companies
	do

		rfile="${appid}_${company}_l_data.err"
		# example: patb_nmcic_l_data.err


		if [[ -a $rfile ]]; then
			et=1
			log $rfile data rejects found
			cat $rfile >> $efile
			perl ${scrdir}uerr.pl $rfile
			cat $rfile.u | mailx -s "$envid ${xapp} $company Data Load Rejects" $recipients
			perl ${scrdir}zarc.pl $rfile
			perl ${scrdir}arc.pl ${rfile}.u
		fi


	done
	if [[ $et -eq 1 ]]; then
		touch ${inpdir}patb.error.token
	fi

fi

## PAIC removed - 20030603 mbowen@mdcbowen.org


## RPLA, RPLB, RPLU
if [[ $apptype = 'rpl' ]]; then
	et=0
	cd ${errdir}
	efile=${appdir}${xapp}/Main/err${today}.txt
	echo '\\\\' $efile > $efile
	# data load rejects only
	## loop through all subs
	for company in $rfin_companies
	do

		# ACT6 files
		rfile="${appid}_${company}_l_data.err"
		# example: rpla_nmcic_l_data.err


		if [[ -a $rfile ]]; then
			et=1
			log $rfile data rejects found
			cat $rfile >> $efile
			perl ${scrdir}uerr.pl $rfile
			cat $rfile.u | mailx -s "$envid ${xapp} $company ACT6 Load Rejects" $recipients
			perl ${scrdir}zarc.pl $rfile
			perl ${scrdir}arc.pl ${rfile}.u
		fi



		# BUD6 files
		rfile="${appid}_${company}_l_bud.err"
		# example: rfin_nmcic_l_bud.err


		if [[ -a $rfile ]]; then
			et=1
			log $rfile data rejects found
			perl ${scrdir}uerr.pl $rfile
			cat $rfile.u | mailx -s "$envid ${xapp} $company BUD6 Load Rejects" $recipients
			perl ${scrdir}zarc.pl $rfile
			perl ${scrdir}arc.pl ${rfile}.u
		fi

	done

	if [[ ! $appid = 'rplu' ]]; then
		# ELIM files
		rfile="${appid}_all_l_elim.err"
		# example: rpla_all_l_elim.err


		if [[ -a $rfile ]]; then
			et=1
			log $rfile data rejects found
			perl ${scrdir}uerr.pl $rfile
			cat $rfile.u | mailx -s "$envid ${xapp} ELIM Load Rejects" $recipients
			perl ${scrdir}zarc.pl $rfile
			perl ${scrdir}arc.pl ${rfile}.u
		fi
	fi

	if [[ $et = 1 ]]; then
		touch ${inpdir}${appid}.error.token
	fi

fi



## RBS
if [[ $appid = 'rbs' ]]; then

	cd ${errdir}
	et=0
	efile=${appdir}RBS/Main/err${today}.txt
	echo '\\\\' $efile > $efile

	# data load rejects only
	## loop through all subs
	for company in $rfin_companies
	do

		# ACT6 files
		rfile="${appid}_${company}6_l_data.err"
		# example: rbs_nmcic6_l_data.err


		if [[ -a $rfile ]]; then
			et=1
			log $rfile data rejects found
			cat $rfile >> $efile
			perl ${scrdir}uerr.pl $rfile
			cat $rfile.u | mailx -s "$envid ${xapp} $company ACT6 Load Rejects" $recipients
			perl ${scrdir}zarc.pl $rfile
			perl ${scrdir}arc.pl ${rfile}.u
		fi



		# BUD6 files
		rfile="${appid}_${company}_l_bud.err"
		# example: rfin_nmcic6_l_data.err


		if [[ -a $rfile ]]; then
			et=1
			log $rfile data rejects found
			perl ${scrdir}uerr.pl $rfile
			cat $rfile.u | mailx -s "$envid ${xapp} $company BUD6 Load Rejects" $recipients
			perl ${scrdir}zarc.pl $rfile
			perl ${scrdir}arc.pl ${rfile}.u
		fi


		# ELIM files
		rfile="${appid}_${company}_l_elim.err"
		# example: rfin_nmcic6_l_data.err


		if [[ -a $rfile ]]; then
			et=1
			log $rfile data rejects found
			perl ${scrdir}uerr.pl $rfile
			cat $rfile.u | mailx -s "$envid ${xapp} $company ELIM Load Rejects" $recipients
			perl ${scrdir}zarc.pl $rfile
			perl ${scrdir}arc.pl ${rfile}.u
		fi


	done
	if [[ $et -eq 1 ]]; then
		touch ${inpdir}rbs.error.token
	fi

fi




### modifications
## 20030508 - mbowen@mdcbowen.org - created concatenated error file for essbase rejects
##            put it in the app subdirectory for ease of reload
##            add error token to inbox.

## 20030619 - mbowen - rid rbsc code added rfem code
## 20030630 - mbowen - rpla, rplb