#!/bin/ksh
############################################################
#       File:       calcer.sh
#       Purpose:    Midnight calcs of Essbase
#
#       Version:
#       Parameters:
#       Created:
#       Author:   mbowen
#       Parameters:
#       User to run with: essbase
#
#	modified 20030508.1000 by mbowen
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


## MAIN

logfile="${logdir}calcer_activity.log"
update=0

live_apps="locl rbs patb rpla rplb rplc rbs"

case $v in
	'P') active_apps="rx10";;
	'D') active_apps="patb";;
	'Q') active_apps="rplu rpla";;
esac

echo $active_apps

if [[ -a ${inpdir}calc.ok ]]; then
	for appid in $active_apps
	do
		log calculating up $appid
		${scrdir}calc.sh $appid
		#log disabled temporarily

	done
else
	log calc not ok per etl
fi


