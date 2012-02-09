#!/bin/ksh
############################################################
#       File:       updateE.sh
#       Purpose:    Auto Refeed of Errors Feed to Essbase
#
#       Version:
#       Parameters:
#       Created:
#       Author:   mbowen@mdcbowen.org
#       Parameters:
#       User to run with: essbase
#
#	modified 20030415.0930 by mbowen
#
############################################################

## this version should run on any box

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


rfin_companies="ana das ims nna nmac ncc ncfi nda nesci nmic nesco nmch nmex nmcic nmisc ntcna nmihc nca nci"
recipients='bowenm@nmc.nna, mcdougm@nmc.nna'

logfile="${logdir}updateE_activity.log"
today=`date '+%m%d'`


## subs
log () {
	TIMESTAMP=`date '+%m/%d/%Y %H:%M:%S'`
	echo "${TIMESTAMP} ${PGMNAME} ${PID} $*" >>$logfile
}

goodnews() {
	TIMESTAMP=`date '+%H:%M:%S'`
	recipients='bowenm@nmc.nna, schwabj@nmc.nna, mcdougm@nmc.nna'
    mailx  -s "${envid} DOUBLE REJECTS PASSED" $recipients <<MEOF
    ${TIMESTAMP} Message: $*
MEOF
}

badnews() {
	TIMESTAMP=`date '+%H:%M:%S'`
	recipients='bowenm@nmc.nna, schwabj@nmc.nna, mcdougm@nmc.nna'
    mailx  -s "${envid} DOUBLE REJECTS FAILED" $recipients <<MEOF
    ${TIMESTAMP} Message: $*
MEOF
}

## app parse
case $appid in
	'rfem')  xapp="RFEM"; db="Main";  valid=1;;
	'locl')  xapp="LOCL"; db="Main";  valid=1;;
	'rbs')  xapp="RBS"; db="Main";  valid=1;;
	'rbsc')  xapp="RBS"; db="Main";  valid=1;;
	'rpla')  xapp="RPLA"; db="Main";  valid=1;;
	'rplb')  xapp="RPLB"; db="Main";  valid=1;;
	'patb')  xapp="PATB"; db="Main";  valid=1;;
	*)	valid=0;;
esac

## UPDATE SECTION ## --------------------------------------------------------

if [[ $valid -eq 1 ]]; then

	echo updateE.sh: fixing rejects for ${xapp}..
	log updating ${xapp}..

	## RUN SPECIFIC UPDATE MSH
	cd $scrdir
	${bindir}essmsh ${appid}_errload.msh > ${logdir}${appid}_errload.log

else
	echo invalid selection for updateE.sh of $appid
	log invalid selection for updateE.sh of $appid
fi


## NOTIFICATION SECTION ##-----------------------------------------------------


## check for errors in the essmsh log
if [[ $valid -eq 1 ]]; then

	cd ${logdir}

	rfile=${appid}_errload.log
	a=`cat $rfile |grep 'ERROR'`

	if [[ -z $a ]]; then
		#zero length - no errors
		log rejects cleared for $appid
		goodnews "$appid passed."
		echo updateE: rejects cleared
	else
		#oops. errors
		log double rejects for $appid
		echo updateE: double rejects found
		touch ${inpdir}${appid}.lock
		a=`cat ${appid}_errload.log`
		badnews "$appid locked." $a
	fi

fi

perl ${scrdir}arc.pl ${appid}_errload.log


### modifications
## 20030508 - mbowen@mdcbowen.org - created concatenated error file for essbase rejects
##            put it in the app subdirectory for ease of reload
##            add error token to inbox.