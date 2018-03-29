#!/bin/bash

export BASE=/opt/xdsi/results/acme/iig-1002
touch $BASE/RAD-69
rm -r $BASE/RAD-69
touch $BASE/RAD-75
rm -r $BASE/RAD-75


export ATTACHMENTS=$BASE/RAD-69/attachments

perl $XDSI/tests/iig/iig-1002/iig-1002-10.pl acme acme__rig_a acme__iig

echo Diffing two files
diff \
  /opt/xdsi/storage/iig/A/CASCA1011-1/images/000000.dcm \
  $ATTACHMENTS/1.3.6.1.4.1.21367.201599.3.201606010958036.1.dcm

diff \
  /opt/xdsi/storage/iig/A/CASCA1011-2/images/000000.dcm \
  $ATTACHMENTS/1.3.6.1.4.1.21367.201599.3.201606010958040.1.dcm

echo Expect two files in attachments folder: $ATTACHMENTS
ls -l $ATTACHMENTS
date
