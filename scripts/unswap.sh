#!/bin/ksh
############################################################
#       File:       swap.sh
#       Purpose:    Generate Latest Update Scripts
#
#       Version:
#       Parameters:
#       Created:
#       Author:   mbowen
#       Parameters:
#       User to run with: essbase
#
############################################################
# Regional DW Update
#
#
# 20030325.1000 - mbowen@mdcbowen.org
# for Nissan USA
#
#	modified 20030417.1730 by mbowen
#
############################################################
# mshfab is called exclusively by update.sh


## this version to run on any box

## init
# whereami
disk=`head -1 ~essbase/disk.dat`
envid=`head -1 ~essbase/env.dat`

appid=$1


errdir="/${disk}03/essbase/rdwmr/errlogs/"
logdir="/${disk}03/essbase/rdwmr/logs/"
expdir="/${disk}03/essbase/rdwmr/export/"
appdir="/${disk}01/vendors/essbase/app/"
scrdir="/${disk}03/essbase/rdwmr/scripts/"
inpdir="/${disk}03/essbase/rdwmr/input/"

rfin_companies="ana das ims nna nmac ncc ncfi nda nesci nmic nesco nmch nmex nmcic nmisc ntcna nmihc nca nci"
recipients='bowenm@nmc.nna, schwabj@nmc.nna, mcdougm@nmc.nna'




## app parse
case $appid in
	'rbs')  xapp="RBS"; db="Main"; valid=1;;
	'rplc')  xapp="RPLC"; db="Main"; valid=1;;
	'rplu')  xapp="RPLU"; db="Main"; valid=1;;
	'patb') xapp="PATB"; db="Main"; valid=1;;
	'locl') xapp="LOCL"; db="Main"; valid=1;;
	*)	valid=0;;
esac


if [[ $valid -eq 1 ]]; then

ESSCMD <<EOD
login localhost system manager;
deletedb ${xapp} Main;
copydb ${xapp}2 Main ${xapp} Main;
logout;
exit;

EOD
fi

echo `date` | mailx -s "$xapp UnSwapped in $envid" $recipients

