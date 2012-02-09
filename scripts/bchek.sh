#!/bin/ksh
############################################################
#       File:       bchek.sh
#       Purpose:    What's in the bucket?
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

bucket=$1

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
extensions="6 9 _p _i _s 6_b 6p 6p_b 9_b"

## app parse
case $bucket in
	'latest') extensions="6 9 _p 6p"; valid=1;;
	'budgets') extensions="6_b 6p_b 9_b"; valid=1;;
	'2003-01') extensions="6 9 _p 6p"; valid=1;;
	'2003-02') extensions="6 9 _p 6p"; valid=1;;
	'2003-03') extensions="6 9 _p 6p"; valid=1;;
	'2003-04') extensions="6 9 _p 6p"; valid=1;;
	'2003-05') extensions="6 9 _p 6p"; valid=1;;
	'2003-06') extensions="6 9 _p 6p"; valid=1;;
	'2003-07') extensions="6 9 _p 6p"; valid=1;;
	'2003-08') extensions="6 9 _p 6p"; valid=1;;
	'bad-token') extensions="6 9 _p 6_b 6p 6p_b 9_b"; valid=1;;
	*)	valid=0;;
esac

echo $envid $bucket > bchek.log
date >> bchek.log
echo ' ' >> bchek.log

if [[ $valid -eq 1 ]]; then


	echo bchek: cranking...

	for company in $rfin_companies
	do

		for ext in $extensions
		do

			# non-budget loop
			root=${company}${ext}
			tfile=${inpdir}${bucket}/${root}.txt


			if [[ -a $tfile ]]; then
				stamp=`ls -l $tfile | cut -c 44-56`
				fsize=`ls -l $tfile | cut -c 35-43`
				echo $root $stamp $fsize
				echo $root $stamp $fsize >> bchek.log
			else
				echo $bucket $root MISSING
				echo $bucket $root MISSING >> bchek.log
			fi


		done

	done

fi

cat bchek.log | mailx -s "$envid Bucket Check - $bucket" $recipients

