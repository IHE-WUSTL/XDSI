#!/bin/bash

export BASE=/opt/xdsi/results/apex/rig-2011
touch $BASE/RAD-69
rm -r $BASE/RAD-69
touch $BASE/RAD-75
rm -r $BASE/RAD-75

export ATTACHMENTS=$BASE/RAD-75/attachments


perl $XDSI/tests/rig/rig-2011/rig-2011-10.pl apex apex__rig

echo diffing DICOM images
export BASE=/opt/xdsi/storage/rig/F/CASCF2021/images
export RAD75=$ATTACHMENTS/1.3.6.1.4.1.21367.201599.3.201606061008031
diff $BASE/000000.dcm $RAD75.1.dcm
diff $BASE/000001.dcm $RAD75.2.dcm
diff $BASE/000002.dcm $RAD75.3.dcm
diff $BASE/000003.dcm $RAD75.4.dcm
diff $BASE/000004.dcm $RAD75.5.dcm
diff $BASE/000005.dcm $RAD75.6.dcm
diff $BASE/000006.dcm $RAD75.7.dcm
diff $BASE/000007.dcm $RAD75.8.dcm
diff $BASE/000008.dcm $RAD75.9.dcm
diff $BASE/000009.dcm $RAD75.10.dcm
diff $BASE/000010.dcm $RAD75.11.dcm
diff $BASE/000011.dcm $RAD75.12.dcm
diff $BASE/000012.dcm $RAD75.13.dcm
diff $BASE/000013.dcm $RAD75.14.dcm
diff $BASE/000014.dcm $RAD75.15.dcm
diff $BASE/000015.dcm $RAD75.16.dcm
diff $BASE/000016.dcm $RAD75.17.dcm
diff $BASE/000017.dcm $RAD75.18.dcm
diff $BASE/000018.dcm $RAD75.19.dcm
diff $BASE/000019.dcm $RAD75.20.dcm
diff $BASE/000020.dcm $RAD75.22.dcm
diff $BASE/000021.dcm $RAD75.23.dcm
diff $BASE/000022.dcm $RAD75.24.dcm
diff $BASE/000023.dcm $RAD75.25.dcm
diff $BASE/000024.dcm $RAD75.26.dcm
diff $BASE/000025.dcm $RAD75.27.dcm
diff $BASE/000026.dcm $RAD75.28.dcm
diff $BASE/000027.dcm $RAD75.29.dcm
diff $BASE/000028.dcm $RAD75.30.dcm
diff $BASE/000029.dcm $RAD75.31.dcm
diff $BASE/000030.dcm $RAD75.32.dcm
diff $BASE/000031.dcm $RAD75.33.dcm
diff $BASE/000032.dcm $RAD75.34.dcm
diff $BASE/000033.dcm $RAD75.35.dcm
diff $BASE/000034.dcm $RAD75.36.dcm
diff $BASE/000035.dcm $RAD75.37.dcm

echo Should see 36 files in this folder: $ATTACHMENTS
#ls -la $ATTACHMENTS
ls -l $ATTACHMENTS | grep dcm | wc
date
