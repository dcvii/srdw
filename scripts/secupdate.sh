#!/bin/ksh
############################################################
#       File:       secupdate.sh
#       Purpose:    Update security in the current environment
#
#       Version:
#       Parameters:
#       Created:
#       Author:   mbowen
#       Parameters:
#       User to run with: essbase
#
#	modified 20030325.1020 by mbowen
#
############################################################
#
#
#
#
## this version to run on any box

## init

# some handy constants
PGMNAME=`basename $0`
PID=$$

appid=$1
# whereami
disk=`head -1 ~essbase/disk.dat`
envid=`head -1 ~essbase/env.dat`

errdir="/${disk}03/essbase/rdwmr/errlogs/"
logdir="/${disk}03/essbase/rdwmr/logs/"
expdir="/${disk}03/essbase/rdwmr/export/"
appdir="/${disk}01/vendors/essbase/app/"
scrdir="/${disk}03/essbase/rdwmr/scripts/"
inpdir="/${disk}03/essbase/rdwmr/input/"
bindir="/${disk}01/vendors/essbase/bin/"

recipients='bowenm@nmc.nna, mcdougm@nmc.nna'

logfile="${logdir}secuirty_activity.log"

date > ${logdir}secupdate.log
echo $envid >> ${logdir}secupdate.log
essmsh ${scrdir}keymaster.msh >> ${logdir}secupdate.log
essmsh ${scrdir}gatekeeper.msh >> ${logdir}secupdate.log

cat ${logdir}secupdate.log | mailx -s "$envid Security Update" $recipients

