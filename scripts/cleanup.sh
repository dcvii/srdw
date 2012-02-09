#!/bin/ksh
############################################################
#       File:       cleanup.sh
#       Purpose:    Clean up the Input Subdirectory
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
# cleanup is called exclusively by poll.sh


## this version to run on any box

## init
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

echo cleanup: cleaning up $appid

cd ${inpdir}
for company in $rfin_companies
do
	# ACT6
	dfile="${company}6.txt"

	if [[ -a ${inpdir}$dfile ]]; then
		mv $dfile latest

	fi

	# ACT6P
	dfile="${company}6p.txt"

	if [[ -a ${inpdir}$dfile ]]; then
		mv $dfile latest

	fi

	# ACT9
	dfile="${company}9.txt"
	if [[ -a ${inpdir}$dfile ]]; then
		mv $dfile latest

	fi



	## RBUD
	dfile="${company}6_b.txt"
	if [[ -a ${inpdir}$dfile ]]; then
		mv $dfile latest

	fi

	# budget files
	bfile="${company}6p_b.txt"

	if [[ -a ${inpdir}$bfile ]]; then
		mv $bfile latest

	fi

	bfile="${company}9_b.txt"
	if [[ -a ${inpdir}$bfile ]]; then
		mv $bfile latest
	fi

	## PATB

	dfile="${company}_p.txt"
	if [[ -a ${inpdir}$dfile ]]; then
		mv $dfile latest

	fi

done

# ELIM files
efile="all_eb.txt"
if [[ -a ${inpdir}$efile ]]; then
	mv $efile latest

fi

efile="allp_eb.txt"
if [[ -a ${inpdir}$efile ]]; then
	mv $efile latest

fi

efile="all_e.txt"
if [[ -a ${inpdir}$efile ]]; then
	mv $efile latest

fi

efile="allp_e.txt"
if [[ -a ${inpdir}$efile ]]; then
	mv $efile latest

fi

rm -f ${inpdir}*.token

echo cleanup: done.


