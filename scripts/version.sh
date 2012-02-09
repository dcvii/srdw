#!/bin/ksh
#############################################################
#       File:       version.sh
#       Purpose:    create & update version file for apps
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
# Regional DW Version Control
#
# 20030306 - mbowen@mdcbowen.org
# for Nissan USA
#
############################################################

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

recipients='bowenm@nmc.nna, lyb@nmc.nna, schwabj@nmc.nna, mcdougm@nmc.nna'
logfile="${logdir}version_activity.log"

## subs
log () {
	TIMESTAMP=`date '+%m/%d/%Y %H:%M:%S'`
	echo "${TIMESTAMP} ${PGMNAME} ${PID} $*" >>$logfile
}


## main

type=0
## app parse
case $appid in
	'srdw') type=1;;
	'rbs') xapp="RBS"; db="Main"; type=2;;
	'rfem') xapp="RFEM"; db="Main"; type=2;;
	'rpla') xapp="RPLA"; db="Main"; type=2;;
	'rplb') xapp="RPLB"; db="Main"; type=2;;
	'rfem') xapp="RFEM"; db="Main"; type=2;;
	'rplc') xapp="RPLC"; db="Main"; type=2;;
	'rplu') xapp="RPLU"; db="Main"; type=2;;
	'rbsc') xapp="RBSC"; db="Main"; type=2;;
	'locl') xapp="LOCL"; db="Main"; type=2;;
	'patb') xapp="PATB"; db="Main"; type=2;;
	*)	type=0;;
esac


if [[ $type -eq 1 ]]; then
	log "$appid version file updated"
	cd ${scrdir}
	perl ver.pl ${appid}.ver

	# get new build number
	bnum=`head -1 ${appid}.ver`
	typeset -R3 x=$bnum   # right(3)
	fspec="${appid}_build${x}_objects.tar"

	tar -cf ${fspec} *.txt *.pl *.sh *.msh ${appid}.ver
	# gzip $fspec
	pkzipc -add -fast -move -silent ${fspec}.zip $fspec
	fspec="${fspec}.zip"
	ls -lt $fspec
	mv $fspec ${expdir}
	cp -p ${appid}.ver ${expdir}

	# auto migration
	${scrdir}spush.sh

fi


if [[ $type -eq 2 ]]; then
	log "${appid} version file updated"
	cd ${expdir}
	perl ${scrdir}ver.pl ${appid}.ver
	# cp -p ${appid}.ver ${expdir}

	# get new build number
	bnum=`head -1 ${appid}.ver`
	typeset -R3 x=$bnum   # right(3)
	fspec="${appid}_build${x}_objects.tar"

	cd ${appdir}${xapp}/Main
	tar -cf ${fspec} *.otl *rep *.csc ${expdir}${appid}.ver
	#gzip $fspec
	pkzipc -add -move -fast -silent ${fspec}.zip $fspec
	fspec="${fspec}.zip"
	ls -lt $fspec
	mv $fspec ${expdir}

	cat ${expdir}${appid}.ver | mailx -s "New $xapp Version in $envid" $recipients
fi



if [[ $type -eq 0 ]]; then
	echo "invalid entry $appid"
fi


## updates

## mbowen - 20030331
## this now looks at the export directory first and then copies the ver
#  file to the app subdirectory.

# mbowen - 20030401: s193 -> srdw

# mbowen - 20030509: remove (finally) rxcp