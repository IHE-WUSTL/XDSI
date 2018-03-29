#!/bin/bash

export BASE=/opt/xdsi/results/apex/rig-2008
touch $BASE/RAD-69
rm -r $BASE/RAD-69
touch $BASE/RAD-75
rm -r $BASE/RAD-75

export ATTACHMENTS=$BASE/RAD-75/attachments


perl $XDSI/tests/rig/rig-2008/rig-2008-10.pl apex apex__rig

echo diffing DICOM images
diff \
  /opt/xdsi/storage/rig/E/CASCE2011-1/images/000000.dcm \
  $ATTACHMENTS/1.3.6.1.4.1.21367.201599.3.201606021454003.1.dcm

echo should see one image in this folder
ls -la $ATTACHMENTS
date
