#!/bin/ksh
############################################################
#       File:       grabqaData.sh
#       Purpose:    Grab data from qa
#
#       Version:
#       Parameters:
#       Created:
#       Author:   jschwab@lynxbic.com
#       Parameters:
#       User to run with: essbase
#
#       modified 
#
############################################################

cd /03fs03/essbase/rdwmr/scripts
snatch.sh 'qa' '2002-12'
snatch.sh 'qa' '2003-01'
snatch.sh 'qa' '2003-02'
snatch.sh 'qa' '2003-03'
snatch.sh 'qa' '2003-04'
snatch.sh 'qa' '2003-05'
snatch.sh 'qa' '2003-06'
snatch.sh 'qa' 'budgets'
snatch.sh 'qa' 'rbs'
snatch.sh 'qa' 'rpl'
snatch.sh 'qa' 'latest'
