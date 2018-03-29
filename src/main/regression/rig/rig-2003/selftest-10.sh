#!/bin/bash

export BASE=/opt/xdsi/results/apex/rig-2003
touch $BASE/RAD-69
rm -r $BASE/RAD-69
touch $BASE/RAD-75
rm -r $BASE/RAD-75

export ATTACHMENTS=$BASE/RAD-75/attachments

perl $XDSI/tests/rig/rig-2003/rig-2003-10.pl apex apex__rig

echo diffing one DICOM image
diff \
  /opt/xdsi/storage/xca-dataset-e/1.3.6.1.4.1.21367.201599.1.201606021454002/1.3.6.1.4.1.21367.201599.2.201606021454003/1.3.6.1.4.1.21367.201599.3.201606021454003.1/1.2.840.10008.1.2.4.70 \
  $ATTACHMENTS/1.3.6.1.4.1.21367.201599.3.201606021454003.1.dcm

echo should see one file in this folder
ls -la $ATTACHMENTS
date
