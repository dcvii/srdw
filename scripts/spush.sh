#!/bin/ksh
############################################################
#       File:       spush.sh
#       Purpose:    send scripts from dev to qa and prod
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
############################################################

## this version to run on any box

## init
# whereami
disk=`head -1 ~essbase/disk.dat`
envid=`head -1 ~essbase/env.dat`

# some handy constants
PGMNAME=`basename $0`
PID=$$

appid=$1


errdir="/${disk}03/essbase/rdwmr/errlogs/"
logdir="/${disk}03/essbase/rdwmr/logs/"
expdir="/${disk}03/essbase/rdwmr/export/"
appdir="/${disk}01/vendors/essbase/app/"
scrdir="/${disk}03/essbase/rdwmr/scripts/"
inpdir="/${disk}03/essbase/rdwmr/input/"


echo "pushing scripts to qa..."
ftp -n <<EOF
open 10.64.6.146
user essbase nardwqa1
cd /146fs03/essbase/rdwmr/scripts
prompt off
mput *.sh
mput *.pl
put keymaster.msh
put gatekeeper.msh
put srdw.ver
cd /146fs03/essbase/rdwmr/export
put srdw.ver
quit
EOF

echo "pushing scripts to prod..."
ftp -n <<EOT
open 10.64.6.143
user essbase nardwp1
cd /143fs03/essbase/rdwmr/scripts
prompt off
mput *.sh
mput *.pl
put keymaster.msh
put gatekeeper.msh
put srdw.ver
cd /143fs03/essbase/rdwmr/export
put srdw.ver
quit
EOT


## only send gatekeeper and keymaster.msh
## send srdw.ver to export directory
