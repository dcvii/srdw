#!/bin/ksh
############################################################
#       File:       snatcher.sh
#       Purpose:    calling program for snatch
#
#       Version:
#       Parameters:
#       Created:  20030624
#       Author:   mbowen@mdcbowen.org
#       Parameters:
#       User to run with: essbase
#
#	modified 20030624.1000 by mbowen
#
############################################################

## this version to run on all boxes

## INIT
# whereami
disk=`head -1 ~essbase/disk.dat`
envid=`head -1 ~essbase/env.dat`
typeset -L1 v=$envid

src=$1

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

logfile="${logdir}snatcher_activity.log"
update=0

buckets="2002-12 2003-01 2003-02 2003-03 2003-04 2003-05 2003-06 2003-07 budgets latest"

for bucket in $buckets
do
	echo snatching $bucket from $src
	${scrdir}snatch.sh $src $bucket
	#log disabled temporarily

done

