#!/bin/bash

export BASE=/opt/xdsi/results/apex/rig-2005
touch $BASE/RAD-69
rm -r $BASE/RAD-69
touch $BASE/RAD-75
rm -r $BASE/RAD-75

export ATTACHMENTS=$BASE/RAD-75/attachments


perl $XDSI/tests/rig/rig-2005/rig-2005-10.pl apex apex__rig

echo should see no files in this folder
ls -la $ATTACHMENTS
