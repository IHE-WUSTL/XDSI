#!/bin/bash

export BASE=/opt/xdsi/results/apex/rig-2021
touch $BASE/RAD-69-E
rm -r $BASE/RAD-69-E
touch $BASE/RAD-69-F
rm -r $BASE/RAD-69-F
touch $BASE/RAD-75
rm -r $BASE/RAD-75

export ATTACHMENTS=$BASE/RAD-75/attachments

perl $XDSI/tests/rig/rig-2021/rig-2021-10.pl apex apex__rig

echo diffing two DICOM images
diff \
  /opt/xdsi/storage/rig/E/CASCE3041-1/images/000000.dcm \
  $ATTACHMENTS/1.3.6.1.4.1.21367.201599.3.201607011605056.1.dcm

diff \
  /opt/xdsi/storage/rig/F/CASCF3041-2/images/000000.dcm \
  $ATTACHMENTS/1.3.6.1.4.1.21367.201599.3.201607011606000.1.dcm

echo should see two files in this folder
ls -la $ATTACHMENTS
date
