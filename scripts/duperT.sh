#!/bin/ksh
############################################################
#       File:       duperT.sh
#       Purpose:    Send All Totals Files to Essbase
#
#       Version:
#       Parameters:
#       Created:
#       Author:   mbowen
#       Parameters:
#       User to run with: essbase
#
#	modified 20030325.1000 by mbowen
#
############################################################

## this version to run on all boxes

## INIT
# whereami
disk=`head -1 ~essbase/disk.dat`
envid=`head -1 ~essbase/env.dat`

appid=$1

# some handy constants
PGMNAME=`basename $0`
PID=$$

# dates in various formats
TODAYHR=`date '+%y%m%d%H'`
TODAY=`date '+%y%m%d'`
THEDATE=`date '+%m/%d/%Y'`
DAYOFWEEK=`date '+%u'`

# Modify for development

errdir="/${disk}03/essbase/rdwmr/errlogs/"
logdir="/${disk}03/essbase/rdwmr/logs/"
expdir="/${disk}03/essbase/rdwmr/export/"
appdir="/${disk}01/vendors/essbase/app/"
scrdir="/${disk}03/essbase/rdwmr/scripts/"
inpdir="/${disk}03/essbase/rdwmr/input/"

recipients='bowenm@nmc.nna, mcdougm@nmc.nna'


## PROCEDURES

log () {
	TIMESTAMP=`date '+%m/%d/%Y %H:%M:%S'`
	echo "${TIMESTAMP} ${PGMNAME} ${PID} $*" >>$logfile
}



rfin_companies="ana das ims nna nmac ncc ncfi nda nesci nmic nesco nmch nmex nmcic nmisc ntcna nmihc nca nci"
extensions="6 9 _p"
months="2002-12 2003-01 2003-02 2003-03 2003-04 2003-05 2003-06"

## app parse
case $appid in
	'rbs')  xapp="RBS"; db="Main"; extensions="6_b 6"; doe=1; valid=1;;
	'rfem') xapp="RFEM"; db="Main"; extensions="_e"; doe=1; valid=0;;
	'rpla') xapp="RPLA"; db="Main"; extensions="6p 6p_b"; doe=1; valid=1;;
	'rplb') xapp="RPLB"; db="Main"; extensions="6p 6p_b"; doe=1; valid=1;;
	'rplu') xapp="RPLU"; db="Main"; extensions="6p 6p_b"; doe=0; valid=1;;
	'patb') xapp="PATB"; db="Main"; extensions="_p"; doe=0; valid=1;;
	'locl') xapp="LOCL"; db="Main"; extensions="9 9_b"; doe=0; valid=1;;
	*)	valid=0;;
esac

echo $envid $xapp > duperT.log
date >> duperT.log
echo ' ' >> duperT.log

if [[ $valid -eq 1 ]]; then

	echo duperT: erasing old $xapp files..
	rm -f ${appdir}${xapp}/Main/*.txt

	echo duperT: $xapp cranking...

	for company in $rfin_companies
	do

		for ext in $extensions
		do

			if [[ $ext = '6_b' || $ext = '9_b' || $ext = '6p_b' ]]; then
				# budget stuff
				root=${company}${ext}
				tfile=${inpdir}budgets/${root}.txt
				if [[ -a $tfile ]]; then
					stamp=`ls -l $tfile | cut -c 44-56`
					fsize=`ls -l $tfile | cut -c 35-43`
					echo $root budgets $stamp $fsize >> duperT.log
				fi
			else
				# non-budget loop
				root=${company}${ext}

				tfile=${inpdir}totals/${root}T.txt
				dfile="${root}.txt"
				rm -f $tfile

				#ebedded supercat: making $tfile
				for month in $months
				do
					cnt=0
					# get files

					# echo searching $month
					if [[ -a ${inpdir}$month/$dfile ]]; then
						new=TRUE
						# load data
						#ls ${inpdir}$month/$dfile
						cat ${inpdir}$month/$dfile >> $tfile
						stamp=`ls -l ${inpdir}$month/$dfile | cut -c 44-56`
						fsize=`ls -l ${inpdir}$month/$dfile | cut -c 35-43`
						echo $root $month $stamp $fsize >> duperT.log
					fi


				done
			fi

			#ok file is finished copy it to the multi company app
			# if there is something in it.
			if [[ -s $tfile ]]; then
				cp -p $tfile ${appdir}${xapp}/Main
				#echo '---' >> duperT.log
			fi

		done

	done

fi

if [[ $doe -eq 1 ]]; then

	echo duperT: $xapp elims...

	# elims - in months!
	dfile="all_e.txt"
	root="all_e"
	tfile=${inpdir}totals/all_eT.txt
	rm -f $tfile

	for month in $months
	do
		if [[ -s ${inpdir}$month/$dfile ]]; then
			cat ${inpdir}$month/$dfile >> $tfile
			stamp=`ls -l ${inpdir}$month/$dfile | cut -c 44-56`
			fsize=`ls -l ${inpdir}$month/$dfile | cut -c 35-43`
			echo $root $month $stamp $fsize >> duperT.log
		fi
	done
	cp -p $tfile ${appdir}${xapp}/Main

	# elims - in months!
	dfile="allp_e.txt"
	root="allp_e"
	tfile=${inpdir}totals/allp_eT.txt
	rm -f $tfile

	for month in $months
	do
		if [[ -s ${inpdir}$month/$dfile ]]; then
			cat ${inpdir}$month/$dfile >> $tfile
			stamp=`ls -l ${inpdir}$month/$dfile | cut -c 44-56`
			fsize=`ls -l ${inpdir}$month/$dfile | cut -c 35-43`
			echo $root $month $stamp $fsize >> duperT.log
		fi
	done
	cp -p $tfile ${appdir}${xapp}/Main



fi

cat duperT.log | mailx -s "$envid $xapp Data Duper - Totals" $recipients

