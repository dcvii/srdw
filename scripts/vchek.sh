#!/bin/ksh
#############################################################
#       File:       vchek.sh
#       Purpose:    display version file for apps
#
#       Version:
#       Parameters:
#       Created:
#       Author:   mbowen@mdcbowen.org
#       Parameters:
#       User to run with: essbase
#
#	modified 20030422.1530 by mbowen
#
#############################################################
# Regional DW Version Control
#
# 20030306 - mbowen@mdcbowen.org
# for Nissan USA
#
############################################################


## init
# whereami
disk=`head -1 ~essbase/disk.dat`
envid=`head -1 ~essbase/env.dat`

# some handy constants
PGMNAME=`basename $0`
PID=$$

appid=$1


errdir="/${disk}03/essbase/rdwmr/errlogs/"
logdir="/${disk}03/essbase/rdwmr/logs/"
expdir="/${disk}03/essbase/rdwmr/export/"
appdir="/${disk}01/vendors/essbase/app/"
scrdir="/${disk}03/essbase/rdwmr/scripts/"
inpdir="/${disk}03/essbase/rdwmr/input/"


recipients='bowenm@nmc.nna, schwabj@nmc.nna, mcdougm@nmc.nna, kahfb@nmc.nna'
today=`date '+%m%d'`

## main

## app parse
applist="srdw rfem patb locl rpla rplb rbs rplu"

date > vercheck.txt
echo $envid >> vercheck.txt

for appid in $applist
do


  echo $appid >> vercheck.txt
  cat ${expdir}${appid}.ver >> vercheck.txt

done

TIMESTAMP=`date '+%m/%d/%Y'`

cat ${logdir}version_activity.log|grep $TIMESTAMP >> vercheck.txt


echo ---- DATA RUNS TODAY ---- >> vercheck.txt
cat ${scrdir}registry.log |grep $today > reg.txt
sort -t: +2 reg.txt >> vercheck.txt
rm -f reg.txt

cat vercheck.txt | mailx -s "${envid} Version Check" $recipients

