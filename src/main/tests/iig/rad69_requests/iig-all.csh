#!/bin/csh

set communityA="urn:oid:1.3.6.1.4.1.21367.13.70.101 1.3.6.1.4.1.21367.13.71.101"
set communityB="urn:oid:1.3.6.1.4.1.21367.13.70.102 1.3.6.1.4.1.21367.13.71.102"
set communityX="urn:oid:1.3.6.1.4.1.21367.13.70.102.999 1.3.6.1.4.1.21367.13.71.102.999"

# 1001, One Image, One Responding Gateway
echo "# iig-1001 One image, one responding gateway" > iig-1001.txt
perl gen_one_study.pl $communityA /opt/xdsi/storage/iig/A/CASCA1011-1/images >> iig-1001.txt

# 1002, Two separate studies, one responding gateway
echo "# iig-1002  Two separate studies, one responding gateway" > iig-1002.txt
echo "# Study 1" >> iig-1002.txt
perl gen_one_study.pl $communityA /opt/xdsi/storage/iig/A/CASCA1011-1/images >> iig-1002.txt

echo "" >> iig-1002.txt
echo "# Study 2" >> iig-1002.txt
perl gen_one_study.pl $communityA /opt/xdsi/storage/iig/A/CASCA1011-2/images >> iig-1002.txt

# 1003, One Image, JPEG Lossless Compression
echo "# iig-1003 One image, JPEG Lossless Compression" > iig-1003.txt
perl gen_one_study.pl $communityA /opt/xdsi/storage/iig/A/CASCA1011-1/images >> iig-1003.txt

# 1004, One Image, Two JPEG transfer syntaxes
echo "# iig-1004 One image, Two JPEG Compression transfer syntaxes" > iig-1004.txt
perl gen_one_study.pl $communityA /opt/xdsi/storage/iig/A/CASCA1011-1/images >> iig-1004.txt

# 1005, One Image, Transfer syntax not supported by RIG
echo "# iig-1005 One image, Transfer syntax not supported by RIG" > iig-1005.txt
perl gen_one_study.pl $communityA /opt/xdsi/storage/iig/A/CASCA1011-1/images >> iig-1005.txt

# 1006, One Image, Unknown DICOM UIDs
echo "# iig-1006 One image, Unknown DICOM UIDs" > iig-1006.txt
perl gen_one_study_with_suffix.pl $communityA /opt/xdsi/storage/iig/A/CASCA1011-1/images .999 >> iig-1006.txt

# 1007, One Image, Unregistered Responding Gateway
echo "# iig-1007 One image, unregistered responding gateway" > iig-1007.txt
perl gen_one_study.pl $communityX /opt/xdsi/storage/iig/A/CASCA1011-1/images >> iig-1007.txt

# 1008, Consolidated Success/Failure, Single Gateway
echo "# iig-1008 Consolidated Success/Failure, Single Gateway" > iig-1008.txt
perl gen_one_study.pl $communityA /opt/xdsi/storage/iig/A/CASCA1011-1/images >> iig-1008.txt
echo "#" >> iig-1008.txt
perl gen_one_study_with_suffix.pl $communityA /opt/xdsi/storage/iig/A/CASCA1011-1/images .999 >> iig-1008.txt

# Now, turn to Community B

# 1011, MR Study, One Community
echo "# iig-1011 MR Study, one responding gateway" > iig-1011.txt
perl gen_one_study.pl $communityB /opt/xdsi/storage/iig/B/CASCB1021/images >> iig-1011.txt

# The following requests are for combined A/B

# 1021, One CR image in A, MR study in B
echo "# iig-1021 One CR image in A, MR study in B" > iig-1021.txt
echo "# CR image, community A" >> iig-1021.txt
perl gen_one_study.pl $communityA /opt/xdsi/storage/iig/A/CASCA1031/images >> iig-1021.txt
echo "#" >> iig-1021.txt
echo "# MR study, community B" >> iig-1021.txt
perl gen_one_study.pl $communityB /opt/xdsi/storage/iig/B/CASCB1031/images >> iig-1021.txt

# 1022, One CR image in A, Error Study in B
echo "# iig-1022 One CR image in A, Error study in B" > iig-1022.txt
echo "# CR image, community A" >> iig-1022.txt
perl gen_one_study.pl $communityA /opt/xdsi/storage/iig/A/CASCA1011-1/images >> iig-1022.txt
echo "#" >> iig-1022.txt
echo "# One image, Unknown DICOM UIDs" >> iig-1022.txt
perl gen_one_study_with_suffix.pl $communityA /opt/xdsi/storage/iig/A/CASCA1011-1/images .999 >> iig-1022.txt
