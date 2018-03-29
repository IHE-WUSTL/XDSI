#!/bin/bash

export BASE=/opt/xdsi/results/acme/iig-1011
touch $BASE/RAD-69
rm -r $BASE/RAD-69
touch $BASE/RAD-75-B
rm -r $BASE/RAD-75-B


export ATTACHMENTS=$BASE/RAD-69/attachments


perl $XDSI/tests/iig/iig-1011/iig-1011-10.pl acme acme__rig_b acme__iig

echo "ls should show 36 entries" $ATTACHMENTS
ls     $ATTACHMENTS | wc
date
