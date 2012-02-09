#!/bin/ksh
############################################################
#       File:       duperL.sh
#       Purpose:    Send All Latest Files to Essbase
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
extensions="6 9 _e _p _i _s"

## app parse
case $appid in
	'rbs') errType="B"; xapp="RBS"; db="Main"; extensions="6_b 6"; valid=1;;
	'rfem') errType="B"; xapp="RFEM"; db="Main"; extensions="_e"; valid=0;;
	'rpla') errType="B"; xapp="RPLA"; db="Main"; extensions="6p 6p_b"; valid=1;;
	'rplb') errType="B"; xapp="RPLB"; db="Main"; extensions="6p 6p_b"; valid=1;;
	'rplu') errType="B"; xapp="RPLU"; db="Main"; extensions="6p 6p_b"; valid=1;;
	'patb') errType="A"; xapp="PATB"; db="Main"; extensions="_p"; valid=1;;
	'locl') errType="B"; xapp="LOCL"; db="Main"; extensions="9 9_b"; valid=1;;
	*)	valid=0;;
esac

echo $envid $xapp > duperL.log
date >> duperL.log
echo ' ' >> duperL.log

if [[ $valid -eq 1 ]]; then

	echo duper: erasing old $xapp files..
	rm -f ${appdir}${xapp}/Main/*.txt

	echo duperL: $xapp cranking...

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
					echo $root budgets $stamp $fsize >> duperL.log
				fi
			else
				# non-budget loop
				root=${company}${ext}
				tfile=${inpdir}latest/${root}.txt
				dfile="${root}.txt"

				if [[ -a ${inpdir}latest/$dfile ]]; then
					new=TRUE
					# load data
					#ls ${inpdir}$month/$dfile
					stamp=`ls -l ${inpdir}latest/$dfile | cut -c 44-56`
					fsize=`ls -l ${inpdir}latest/$dfile | cut -c 35-43`
					echo $root latest $stamp $fsize >> duperL.log
				fi


			fi

			#ok file is finished copy it to the multi company app
			# if there is something in it.
			if [[ -s $tfile ]]; then
				cp -p $tfile ${appdir}${xapp}/Main
				#echo '---' >> duperL.log
			fi

		done

	done

	# elims
	dfile="all_e.txt"
	root="all_e"
	if [[ -s ${inpdir}latest/$dfile ]]; then
		stamp=`ls -l ${inpdir}latest/$dfile | cut -c 44-56`
		fsize=`ls -l ${inpdir}latest/$dfile | cut -c 35-43`
		echo $root latest $stamp $fsize >> duperL.log
		cp -p ${inpdir}latest/$dfile ${appdir}${xapp}/Main
	fi

fi

if [[ $appid = 'rfem' ]]; then
	# elims only
	dfile="all_e.txt"
	root="all_e"
	if [[ -s ${inpdir}latest/$dfile ]]; then
		stamp=`ls -l ${inpdir}latest/$dfile | cut -c 44-56`
		fsize=`ls -l ${inpdir}latest/$dfile | cut -c 35-43`
		echo $root latest $stamp $fsize >> duperL.log
		cp -p ${inpdir}latest/$dfile ${appdir}${xapp}/Main
	fi
fi

cat duperL.log | mailx -s "$envid $xapp Data Duper - Latest" $recipients

