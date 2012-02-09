#!/bin/ksh
#############################################################
#       File:       stats.sh
#       Purpose:    display getdbinfo file for apps
#
#       Version:
#       Parameters:
#       Created:
#       Author:   mbowen@mdcbowen.org
#       Parameters:
#       User to run with: essbase
#
#	modified 20030328.1530 by mbowen
#
#############################################################
# Regional DW Essbase Stats
#
# 20030306 - mbowen@mdcbowen.org
# for Nissan USA
#
#######################

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
bindir="/${disk}01/vendors/essbase/bin/"

## app parse
case $appid in
	'rfem') xapp="RFEM"; db="Main";  valid=1;;
	'rbs') xapp="RBS"; db="Main";  valid=1;;
	'rpla') xapp="RPLA"; db="Main";  valid=1;;
	'rplb') xapp="RPLB"; db="Main";  valid=1;;
	'rplu') xapp="RPLU"; db="Main";  valid=1;;
	'patb') xapp="PATB"; db="Main";  valid=1;;
	'locl') xapp="LOCL"; db="Main";  valid=1;;
	*)	valid=0;;
esac


if [[ $valid = 1 ]]; then


${bindir}ESSCMD <<EOF
login localhost system manager
select $xapp $db
getdbstats
logout
exit
EOF

else

	echo invalid selection for stats.sh
fi
