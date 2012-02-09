#!/bin/ksh
############################################################
#       File:       poll.sh
#       Purpose:    Auto Feed to Essbase
#
#       Version:
#       Parameters:
#       Created:
#       Author:   mbowen@mdcbowen.org
#       Parameters:
#       User to run with: essbase
#
#	modified 20030321.0900 by mbowen
#
############################################################

## this version should run on any box

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


notify() {
	TIMESTAMP=`date '+%H:%M:%S'`
	recipients='bowenm@nmc.nna, schwabj@nmc.nna, mcdougm@nmc.nna'
    mailx  -s "${envid} Poll Results" $recipients <<MEOF
    ${TIMESTAMP} Message: $*
MEOF
}


log () {
	TIMESTAMP=`date '+%m/%d/%Y %H:%M:%S'`
	echo "${TIMESTAMP} ${PGMNAME} ${PID} $*" >>$logfile
}


## MAIN


logfile="${logdir}poll_activity.log"
update=0
doerr=1

clear

## NORMAL LOOP
echo "poll: normal loop"

case $v in
	'P') active_apps="patb locl rpla rplb rplu rbs";;
	'D') active_apps="patb locl rpla rplb rplu rbs";;
	'Q') active_apps="patb locl rpla rplu rbs";;
esac


for appid in $active_apps
do

	typeset -u xapp=$appid
	normal_token="${inpdir}${appid}.token"
	lock="${inpdir}${appid}.lock"

	case $appid in
		'patb')	normal_token="pigsfly"; docalc=0;; # totals only
		'locl') docalc=1;;
		'rpla')	normal_token="pigsfly"; docalc=0;; # totals only
		'rplu')	normal_token="pigsfly"; docalc=0;; # totals only
		'rplb')	normal_token="pigsfly"; docalc=0;; # totals only
		'rbs')  docalc=1;;
		'rfem')  normal_token="pigsfly"; docalc=1;; # totals only
	esac


	# normal pass
	if [[ -a $normal_token && ! -a $lock ]]; then

		echo "poll: found normal token for $xapp."
		log "found normal token for $xapp."
		update=1

		# file links were done in prepoll.sh

		touch $lock
		${scrdir}mshfab.sh $appid
		${scrdir}update.sh $appid

		if [[ $docalc -eq 1 ]]; then
			${scrdir}calc.sh $appid
		fi

		rm -f $normal_token
		rm -f $lock

	fi
done


## TOTALS PASS
active_apps="patb locl rpla rplu rbs rfem"
echo "poll: totals loop"
for appid in $active_apps
do

	typeset -u xapp=$appid

	totals_token="${inpdir}${appid}.totals.token"
	lock="${inpdir}${appid}.lock"

	case $appid in
		'patb')	totals_token="${inpdir}${appid}.token"; docalc=1;; #always totals
		'locl') docalc=1;;
		'rplb')	totals_token="${inpdir}${appid}.token"; docalc=0;; #always totals
		'rpla')	totals_token="${inpdir}${appid}.token"; docalc=0;; #always totals
		'rplu')	totals_token="${inpdir}${appid}.token"; docalc=0;; #always totals
		'rbs')  docalc=1;;
		'rfem')  totals_token="${inpdir}${appid}.token"; docalc=1;; #always totals
	esac

	# always only process rfem from scratch

	# totals pass
	if [[ -a $totals_token && ! -a $lock ]]; then

		echo "poll: found totals token for $xapp."
		log "found totals token for $xapp."
		update=1

		# file links were done in prepoll.sh

		touch $lock
		${scrdir}duperT.sh $appid
		${scrdir}mshfabT.sh $appid
		${scrdir}update.sh $appid

		if [[ $docalc -eq 1 ]]; then
			${scrdir}calc.sh $appid
		fi

		rm -f $totals_token
		rm -f $lock

	fi
done


## LATEST PASS
active_apps="patb locl rpla rbs rplb rplu rfem"
echo "poll: latest loop"
for appid in $active_apps
do

	case $appid in
		'patb')	docalc=1;;
		'locl') docalc=1;;
		'rpla')	docalc=0;;
		'rplu')	docalc=0;;
		'rplb')	docalc=0;;
		'rbs')  docalc=1;;
		'rfem')  docalc=1;;
	esac

	typeset -u xapp=$appid

	normal_token="${inpdir}${appid}.token"
	totals_token="${inpdir}${appid}.totals.token"
	latest_token="${inpdir}${appid}.latest.token"
	error_token="${inpdir}${appid}.error.token"
	lock="${inpdir}${appid}.lock"

	# totals pass
	if [[ -a $latest_token && ! -a $lock ]]; then

		echo "poll: found latest token for $xapp."
		log "found latest token for $xapp."
		update=1

		# file links were done in prepoll.sh

		touch $lock
		${scrdir}duperL.sh $appid
		${scrdir}mshfabL.sh $appid
		${scrdir}update.sh $appid

		if [[ $docalc -eq 1 ]]; then
			${scrdir}calc.sh $appid
		fi

		rm -f $latest_token
		rm -f $lock

	fi
done

## ERROR PASS
active_apps="patb locl rpla rbs rfem"
echo "poll: error loop"

case $v in
	'P') active_apps="locl patb";;
	'D') active_apps="patb locl";;
	'Q') active_apps="patb locl";;
esac

for appid in $active_apps
do

	case $appid in
		'patb')	docalc=1;;
		'locl') docalc=1;;
		'rpla')	docalc=0;;
		'rplb')	docalc=0;;
		'rbs')  docalc=1;;
		'rplu')	docalc=0;;
		'rfem')  docalc=1;;
	esac

	typeset -u xapp=$appid

	normal_token="${inpdir}${appid}.token"
	totals_token="${inpdir}${appid}.totals.token"
	latest_token="${inpdir}${appid}.latest.token"
	error_token="${inpdir}${appid}.error.token"
	lock="${inpdir}${appid}.lock"

	# totals pass
	if [[ -a $error_token && ! -a $lock && $doerr -eq 1 ]]; then

		echo "poll: found error token for $xapp."
		log "found error token for $xapp."
		update=1

		# file links were done in prepoll.sh

		touch $lock
		${scrdir}mshfabE.sh $appid
		${scrdir}updateE.sh $appid

		if [[ $docalc -eq 1 ]]; then
			 ${scrdir}calc.sh $appid
		fi

		notify "error found for $appid"
		rm -f $error_token
		rm -f $lock

	fi
done


if [[ $update -eq 0 ]]; then
	log "no new tokens found"
	echo "poll: No new data."
	notify "No new data."

	echo "poll: cleaning up"
	${scrdir}cleanup.sh

fi

## calc everything automatically except rpla and rplb
