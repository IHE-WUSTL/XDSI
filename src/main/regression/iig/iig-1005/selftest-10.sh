#!/bin/bash

export BASE=/opt/xdsi/results/acme/iig-1005
touch $BASE/RAD-69
rm -r $BASE/RAD-69
touch $BASE/RAD-75
rm -r $BASE/RAD-75

export ATTACHMENTS=$BASE/RAD-69/attachments


perl $XDSI/tests/iig/iig-1005/iig-1005-10.pl acme acme__rig_a acme__iig

echo "ls should show 0 entries"
ls -l $ATTACHMENTS
