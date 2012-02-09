#!/bin/ksh
############################################################
#       File:       wipe.sh
#       Purpose:    Rid All Tokens for testing
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
#############################################################
#
#
# 20030325.1030 - mbowen@mdcbowen.org
# for Nissan USA
#
#############################################################

# should run on any box

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

rfin_companies="ana das ims nna nmac ncc ncfi nda nesci nmic nesco nmch nmex nmcic nmisc ntcna nmihc nca nci"
recipients='bowenm@nmc.nna, schwabj@nmc.nna, mcdougm@nmc.nna'



echo wiping tokens..

rm -f ${inpdir}*.token

rm -f ${inpdir}rfin/*.token

