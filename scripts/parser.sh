#!/bin/ksh
############################################################
#       File:       parser.sh
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

altdate=$1


period=`date '+%b %d'`
p=`echo "'"$period"'"`
# echo checking on $p...




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

logfile="${logdir}parser_activity.log"
update=0

active_apps="PATB PATB2 LOCL LOCL2 RPL RPL2 RBS RBS2 RBSC RBSC2 RPLU RPLU2 RPLU3 RPLA RPLB"
#active_apps="PATB"


echo $envid > parser.log
date >> parser.log
cd $scrdir

for appid in $active_apps
do
	sfile="${appdir}${appid}/${appid}.log"

	if [[ -a $sfile ]]; then

		# echo $sfile
		cp $sfile ${appid}.log

		perl parse3.pl $appid $1 >> parser.log
		# echo '---- parser ----' >> parser.log
		rm ${appid}.log
	fi

done

cat parser.log | mailx -s "$envid Query Stats" bowenm@nmc.nna                     