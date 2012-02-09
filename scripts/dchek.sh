#!/bin/ksh
#############################################################
#       File:       vchek.sh
#       Purpose:    display data stuff for today's runs
#
#       Version:
#       Parameters:
#       Created:
#       Author:   mbowen@mdcbowen.org
#       Parameters:
#       User to run with: essbase
#
#	modified 200300501.1130 by mbowen
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

dat=$1


errdir="/${disk}03/essbase/rdwmr/errlogs/"
logdir="/${disk}03/essbase/rdwmr/logs/"
expdir="/${disk}03/essbase/rdwmr/export/"
appdir="/${disk}01/vendors/essbase/app/"
scrdir="/${disk}03/essbase/rdwmr/scripts/"
inpdir="/${disk}03/essbase/rdwmr/input/"


recipients='bowenm@nmc.nna, schwabj@nmc.nna, mcdougm@nmc.nna'


if [[ -n $dat ]]; then
	today=$dat
	t=$dat
else
	today=`date '+%Y%m%d'`
	t="TODAY"
fi

## main


date > datcheck.txt
echo $envid >> datcheck.txt

TIMESTAMP=`date '+%m/%d/%Y'`


echo "---- DATA RUNS $t - date order ----" >> datcheck.txt
cat ${scrdir}registry.log |grep $today >> datcheck.txt
echo ' ' >> datcheck.txt

echo "---- DATA RUNS $t - type order ----" >> datcheck.txt
cat ${scrdir}registry.log |grep $today > reg.txt
sort -t: +2 reg.txt >> datcheck.txt
rm -f reg.txt
echo ' ' >> datcheck.txt

echo "---- DATA RUNS $t - company order ----" >> datcheck.txt
cat ${scrdir}registry.log |grep $today > reg.txt
sort -t: +1 reg.txt >> datcheck.txt
rm -f reg.txt

cat datcheck.txt | mailx -s "${envid} Data Run Check - $today" $recipients

