#!/bin/ksh
############################################################
#       File:       supercat.sh
#       Purpose:    Concatenates files across month buckets for historical loads.
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


## PROCEDURES

log () {
	TIMESTAMP=`date '+%m/%d/%Y %H:%M:%S'`
	echo "${TIMESTAMP} ${PGMNAME} ${PID} $*" >>$logfile
}


rfile=$1

months="2002-12 2003-01 2003-02 2003-03 2003-04 2003-05 2003-06"

tfile=${inpdir}totals/${rfile}T.txt
dfile="${rfile}.txt"
rm -f $tfile
touch $tfile
echo supercat: making $tfile


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
	fi

done

ls -l $tfile

#if the file size is zero, delete it.
if [[ ! -s $tfile ]]; then
	rm -f $tfile
fi
