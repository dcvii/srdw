#!/bin/ksh
############################################################
#       File:       rschek.sh
#       Purpose:    Check to see if the Hyperion Reports Server is responding
#
#       Version:
#       Parameters:
#       Created:
#       Author:   jschwab@lynxbic.com
#       Parameters:
#       User to run with: essbase
#
#       modified: 20030625.1445 mbowen@mdcbowen.org
#
############################################################

## this version to run on all boxes

## INIT
# whereami
disk=`head -1 ~essbase/disk.dat`
envid=`head -1 ~essbase/env.dat`


errdir="/${disk}03/essbase/rdwmr/errlogs/"
logdir="/${disk}03/essbase/rdwmr/logs/"
expdir="/${disk}03/essbase/rdwmr/export/"
appdir="/${disk}01/vendors/essbase/app/"
scrdir="/${disk}03/essbase/rdwmr/scripts/"
inpdir="/${disk}03/essbase/rdwmr/input/"

recipients='bowenm@nmc.nna, mcdougm@nmc.nna, schwabj@nmc.nna'

logfile="${logdir}rschek_activity.log"

## subs
log () {
	TIMESTAMP=`date '+%m/%d/%Y %H:%M:%S'`
	echo "${TIMESTAMP} ${PGMNAME} ${PID} $*" >>$logfile
}


# note that bget.pl is executable.
# use bget to create the HRCheck.txt file as response to http request
${scrdir}bget.pl -B -h http://ncenaw32/HReports/Logon_Main.jsp > ${scrdir}HRCheck.txt
#${scrdir}bget.pl -B -h http://ncenaw32/HMain.jsp > ${scrdir}HRCheck.txt

# check the results and spit the first line iff it contains '200 OK'
ok=`head -1 ${scrdir}HRCheck.txt | grep '200 OK'`

#null string?
if [[ -z $ok ]]; then
	log rschek.sh: ncenaw32 report server unrepsonsive
	echo rschek.sh: ncenaw32 report server unrepsonsive `date`
	cat ${scrdir}HRCheck.txt | mailx -s "NCENAW32 REPORTS SERVER DOWN" $recipients
else
	log rschek.sh: ncenaw32 report server responsive
#	echo rschek.sh: ncenaw32 report server responsive `date`
fi

### mods
#   20030625 - mbowen
#	now activity is logged. messaging is handled here rather than from a perl parser.
#	text of HRCheck is sent in the message to distinguish between error codes from the server
