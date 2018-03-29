#!/bin/bash

export BASE=/opt/xdsi/results/acme/iig-1021
touch $BASE/RAD-69
rm -r $BASE/RAD-69
touch $BASE/RAD-75-A
rm -r $BASE/RAD-75-A
touch $BASE/RAD-75-B
rm -r $BASE/RAD-75-B


perl $XDSI/tests/iig/iig-1021/iig-1021-10.pl acme acme__rig_a acme__iig
echo diff CR image
diff \
  /opt/xdsi/storage/iig/A/CASCA1031/images/000000.dcm \
  /opt/xdsi/results/acme/iig-1021/RAD-69/attachments/1.3.6.1.4.1.21367.201599.3.201606010958048.1.dcm

echo diff MR images
# Do the first one by hand because the time stamp is off compared to the other images
diff \
  /opt/xdsi/storage/iig/B/CASCB1031/images/000000.dcm \
  /opt/xdsi/results/acme/iig-1021/RAD-69/attachments/1.3.6.1.4.1.21367.201599.3.201606010958052.1.dcm

BASE=/opt/xdsi/storage/iig/B/CASCB1031/images
ATTACHMENT=/opt/xdsi/results/acme/iig-1021/RAD-69/attachments/1.3.6.1.4.1.21367.201599.3.201606010958053
diff $BASE/000001.dcm $ATTACHMENT.dcm
diff $BASE/000002.dcm $ATTACHMENT.1.dcm
diff $BASE/000003.dcm $ATTACHMENT.2.dcm

diff $BASE/000004.dcm $ATTACHMENT.3.dcm
diff $BASE/000005.dcm $ATTACHMENT.4.dcm
diff $BASE/000006.dcm $ATTACHMENT.5.dcm
diff $BASE/000007.dcm $ATTACHMENT.6.dcm
diff $BASE/000008.dcm $ATTACHMENT.7.dcm
diff $BASE/000009.dcm $ATTACHMENT.8.dcm
diff $BASE/000010.dcm $ATTACHMENT.9.dcm
diff $BASE/000011.dcm $ATTACHMENT.10.dcm
diff $BASE/000012.dcm $ATTACHMENT.11.dcm
diff $BASE/000013.dcm $ATTACHMENT.12.dcm
diff $BASE/000014.dcm $ATTACHMENT.13.dcm
diff $BASE/000015.dcm $ATTACHMENT.14.dcm
diff $BASE/000016.dcm $ATTACHMENT.15.dcm
diff $BASE/000017.dcm $ATTACHMENT.16.dcm
diff $BASE/000018.dcm $ATTACHMENT.17.dcm
diff $BASE/000019.dcm $ATTACHMENT.18.dcm
diff $BASE/000020.dcm $ATTACHMENT.20.dcm
diff $BASE/000021.dcm $ATTACHMENT.21.dcm
diff $BASE/000022.dcm $ATTACHMENT.22.dcm
diff $BASE/000023.dcm $ATTACHMENT.23.dcm
diff $BASE/000024.dcm $ATTACHMENT.24.dcm
diff $BASE/000025.dcm $ATTACHMENT.25.dcm
diff $BASE/000026.dcm $ATTACHMENT.26.dcm
diff $BASE/000027.dcm $ATTACHMENT.27.dcm
diff $BASE/000028.dcm $ATTACHMENT.28.dcm
diff $BASE/000029.dcm $ATTACHMENT.29.dcm
diff $BASE/000030.dcm $ATTACHMENT.30.dcm
diff $BASE/000031.dcm $ATTACHMENT.31.dcm
diff $BASE/000032.dcm $ATTACHMENT.32.dcm
diff $BASE/000033.dcm $ATTACHMENT.33.dcm
diff $BASE/000034.dcm $ATTACHMENT.34.dcm
diff $BASE/000035.dcm $ATTACHMENT.35.dcm

export ATTACHMENT_FOLDER=/opt/xdsi/results/acme/iig-1021/RAD-69/attachments
echo Should see 37 files in attachments folder: $ATTACHMENT_FOLDER
ls -l $ATTACHMENT_FOLDER | grep dcm | wc
date

