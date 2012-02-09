#!/bin/ksh
############################################################
#       File:       snatch.sh
#       Purpose:    Grab bucket files from other environment
#       Version:
#       Parameters:
#       Created:
#       Author:   mbowen
#       Parameters:
#       User to run with: essbase
#
#	modified 20030602.1000 by mbowen
#
############################################################

## this version to run on all boxes

## INIT
# whereami
disk=`head -1 ~essbase/disk.dat`
envid=`head -1 ~essbase/env.dat`
typeset -L1 v=$envid #P is production


# some handy constants
PGMNAME=`basename $0`
PID=$$
fromenv=$1
bucket=$2


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


##  parse
case $fromenv in
	'qa') x="Q"; ip="10.64.6.146"; user="essbase nardwqa1"; folder="/146fs03/essbase/rdwmr/input/";;
	'prod') x="P"; ip="10.64.6.143"; user="essbase nardwp1"; folder="/143fs03/essbase/rdwmr/input/";;
	'dev') x="D"; ip="10.70.95.193"; user="essbase nardwdv1"; folder="/03fs03/essbase/rdwmr/input/";;
	*)	bucket="error"; valid=0;;
esac

typeset -L1 x=$fromenv


case $bucket in
	'2002-12')  valid=1;;
	'2003-01')  valid=1;;
	'2003-02')  valid=1;;
	'2003-03')  valid=1;;
	'2003-04')  valid=1;;
	'2003-05')  valid=1;;
	'2003-06')  valid=1;;
	'totals')  valid=1;;
	'budgets')  valid=1;;
	'latest')  valid=1;;
	'rpl')  valid=1;;
	'rbs')  valid=1;;
	*)	valid=0;;
esac

if [[ $x = $v ]]; then
	echo snatch: cant move to self
	valid=0
fi

## MAIN

logfile="${logdir}snatch_activity.log"
update=0

# fetch routine
if [[ $valid -eq 1 ]]; then

cd ${inpdir}$bucket
ftp -n <<EO
open $ip
user $user
cd ${folder}${bucket}
prompt off
i
mget *.txt
EO

ls -l

else
	echo snatch: invalid selection
fi



