#!/bin/ksh
############################################################
#       File:       combo.sh
#       Purpose:    Generate Combos for Buyer/Seller Interco
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

rfin_companies="ANA DAS IMS NNA NMAC NCC NCFI NDA NESCI NMIC NESCO NMCH NMEX NMCIC NMISC NTCNA NMIHC NCA NCI GLBL NULL"
recipients='bowenm@nmc.nna'


date > combo.txt
date > seller.txt

for first in $rfin_companies
do

	for second in $rfin_companies
	do

		echo "$first - IC-${second}" >> combo.txt
	#	if [[ ! $first = $second ]]; then
	#		echo "$second - IC-${first}" >> combo.txt
	#	fi

	done
	echo ' ' >> combo.txt
done

                   