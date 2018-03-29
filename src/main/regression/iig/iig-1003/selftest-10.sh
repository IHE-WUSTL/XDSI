#!/bin/bash

export BASE=/opt/xdsi/results/acme/iig-1003
touch $BASE/RAD-69
rm -r $BASE/RAD-69
touch $BASE/RAD-75
rm -r $BASE/RAD-75

export ATTACHMENTS=$BASE/RAD-69/attachments

perl $XDSI/tests/iig/iig-1003/iig-1003-10.pl acme acme__rig_a acme__iig

echo Diffing DICOM/JPEG image
diff \
  $ATTACHMENTS/1.3.6.1.4.1.21367.201599.3.201606010958036.1.dcm \
  /opt/xdsi/storage/ids-community-A/1.3.6.1.4.1.21367.201599.1.201606010958036/1.3.6.1.4.1.21367.201599.2.201606010958036/1.3.6.1.4.1.21367.201599.3.201606010958036.1/1.2.840.10008.1.2.4.70

echo ""
echo Expect one image in attachments folder: $ATTACHMENTS
ls -l $ATTACHMENTS
date
