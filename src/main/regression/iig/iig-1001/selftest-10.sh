#!/bin/bash


touch /opt/xdsi/results/acme/iig-1001/RAD-69
rm -r /opt/xdsi/results/acme/iig-1001/RAD-69
touch /opt/xdsi/results/acme/iig-1001/RAD-75
rm -r /opt/xdsi/results/acme/iig-1001/RAD-75

perl $XDSI/tests/iig/iig-1001/iig-1001-10.pl acme acme__rig_a acme__iig

echo Diff one DICOM image
diff \
  /opt/xdsi/storage/iig/A/CASCA1011-1/images/000000.dcm \
  /opt/xdsi/results/acme/iig-1001/RAD-69/attachments/1.3.6.1.4.1.21367.201599.3.201606010958036.1.dcm

echo Expect one file in this folder /opt/xdsi/results/acme/iig-1001/RAD-69/attachments
ls -l /opt/xdsi/results/acme/iig-1001/RAD-69/attachments
