#!/bin/bash

export BASE=/opt/xdsi/results/acme/iig-1022
touch $BASE/RAD-69
rm -r $BASE/RAD-69
touch $BASE/RAD-75-A
rm -r $BASE/RAD-75-A
touch $BASE/RAD-75-B
rm -r $BASE/RAD-75-B

export ATTACHMENTS=/opt/xdsi/results/acme/iig-1022/RAD-69/attachments

perl $XDSI/tests/iig/iig-1022/iig-1022-10.pl acme acme__rig_a acme__iig

echo diff CR image
diff \
  /opt/xdsi/storage/iig/A/CASCA1011-1/images/000000.dcm \
  $ATTACHMENTS/1.3.6.1.4.1.21367.201599.3.201606010958036.1.dcm

echo There should be one file in the attachments folder: $ATTACHMENTS
ls -la $ATTACHMENTS
date
