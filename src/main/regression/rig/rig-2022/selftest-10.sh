#!/bin/bash

export BASE=/opt/xdsi/results/apex/rig-2022
touch $BASE/RAD-69
rm -r $BASE/RAD-69
touch $BASE/RAD-75
rm -r $BASE/RAD-75

export ATTACHMENTS=$BASE/RAD-75/attachments

perl $XDSI/tests/rig/rig-2022/rig-2022-10.pl apex apex__rig

echo diffing one DICOM image
diff \
  /opt/xdsi/storage/rig/E/CASCE3041-1/images/000000.dcm \
  $ATTACHMENTS/1.3.6.1.4.1.21367.201599.3.201607011605056.1.dcm

echo should see one file in this folder
ls -la $ATTACHMENTS
date
