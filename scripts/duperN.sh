#!/bin/ksh
############################################################
#       File:       duperN.sh
#       Purpose:    Send All normal Files to Essbase
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
# this uses the 'latest' bucket and copies all files to Essbase appdirs
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
extensions="6 9 _e _p"

## app parse
case $appid in
	'mex6') errType="A"; xapp="MEX6"; db="Main"; extensions="6"; valid=0;;
	'rbs') errType="B"; xapp="RBS"; db="Main"; extensions="6_b 6 _e"; valid=1;;
	'rplu') errType="B"; xapp="RPLU"; db="Main"; extensions="6p 6p_b"; valid=1;;
	'rplc') errType="B"; xapp="RPLC"; db="Main"; extensions="6p 6p_b _e"; valid=1;;
	'patb') errType="A"; xapp="PATB"; db="Main"; extensions="_p"; valid=1;;
	'locl') errType="B"; xapp="LOCL"; db="Main"; extensions="9 9_b"; valid=1;;
	'rfin') errType="B"; xapp="RFIN"; db="Main"; extensions="6 _e _s 6_b"; valid=1;;
	*)	valid=0;;
esac

echo $envid $xapp > duperN.log
date >> duperN.log
echo ' ' >> duperN.log

if [[ $valid -eq 1 ]]; then

	echo duper: erasing old $xapp files..
	rm -f ${appdir}${xapp}/Main/*.txt

	echo duperN: $xapp cranking...

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
					echo $root budgets $stamp $fsize >> duperN.log
				fi
			else
				# non-budget loop
				root=${company}${ext}
				tfile=${inpdir}${root}.txt
				dfile="${root}.txt"

				if [[ -a ${inpdir}latest/$dfile ]]; then
					new=TRUE
					# load data
					#ls ${inpdir}$month/$dfile
					stamp=`ls -l ${inpdir}latest/$dfile | cut -c 44-56`
					fsize=`ls -l ${inpdir}latest/$dfile | cut -c 35-43`
					echo $root latest $stamp $fsize >> duperN.log
				fi


			fi

			#ok file is finished copy it to the multi company app
			# if there is something in it.
			if [[ -s $tfile ]]; then
				cp -p $tfile ${appdir}${xapp}/Main
				#echo '---' >> duperN.log
			fi

		done

	done
	# elims
	dfile="all_e.txt"
	if [[ -s ${inpdir}latest/$dfile ]]; then
		stamp=`ls -l ${inpdir}latest/$dfile | cut -c 44-56`
		fsize=`ls -l ${inpdir}latest/$dfile | cut -c 35-43`
		echo $root latest $stamp $fsize >> duperL.log
		cp -p ${inpdir}latest/$dfile ${appdir}${xapp}/Main
	fi

fi

cat duperN.log | mailx -s "$envid $xapp Data Duper - Normal" $recipients

