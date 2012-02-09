#!/bin/ksh
############################################################
#       File:       checkReportsServer.sh
#       Purpose:    Check to see if the Hyperion Reports Server is responding
#
#       Version:
#       Parameters:
#       Created:
#       Author:   jschwab@lynxbic.com
#       Parameters:
#       User to run with: essbase
#
#       modified
#
############################################################

## this version should run on any box


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

recipients='bowenm@nmc.nna, mcdougm@nmc.nna schwabj@nmc.nna'

${scrdir}bget.pl -B -h http://ncenaw32/HReports/Logon_Main.jsp > HRCheck.txt
HRResponseCheck.pl HRCheck.txt

