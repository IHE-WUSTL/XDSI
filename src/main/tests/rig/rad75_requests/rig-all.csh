#!/bin/csh

set communityE="urn:oid:1.3.6.1.4.1.21367.13.70.201 1.3.6.1.4.1.21367.13.71.201.1"
set communityF="urn:oid:1.3.6.1.4.1.21367.13.70.201 1.3.6.1.4.1.21367.13.71.201.2"

# Community Z is for an unknown Imaging Doc Source / Repository Unique ID
set communityZ="urn:oid:1.3.6.1.4.1.21367.13.70.201 1.3.6.1.4.1.21367.13.71.201.2.999"

# 2001, One Image, One IDS
echo "# rig-2001 One image, one IDS " > rig-2001.txt
perl ../../iig/rad69_requests/gen_one_study.pl $communityE /opt/xdsi/storage/rig/E/CASCE2011-1/images ids >> rig-2001.txt

# 2002, Two separate studies, one responding gateway
echo "# rig-2002  Two separate studies, one IDS" > rig-2002.txt
echo "# Study 1" >> rig-2002.txt
perl ../../iig/rad69_requests/gen_one_study.pl $communityE /opt/xdsi/storage/rig/E/CASCE2011-1/images ids >> rig-2002.txt

echo "" >> rig-2002.txt
echo "# Study 2" >> rig-2002.txt
perl ../../iig/rad69_requests/gen_one_study.pl $communityE /opt/xdsi/storage/rig/E/CASCE2011-2/images ids >> rig-2002.txt

# 2003, One Image, JPEG Lossless Compression
echo "# rig-2003 One image, JPEG Lossless Compression" > rig-2003.txt
perl ../../iig/rad69_requests/gen_one_study.pl $communityE /opt/xdsi/storage/rig/E/CASCE2011-1/images ids >> rig-2003.txt

# 2004, One Image, Two JPEG transfer syntaxes
echo "# rig-2004 One image, Two JPEG Compression transfer syntaxes" > rig-2004.txt
perl ../../iig/rad69_requests/gen_one_study.pl $communityE /opt/xdsi/storage/rig/E/CASCE2011-1/images ids >> rig-2004.txt

# 2005, One Image, Transfer syntax not supported by IDS
echo "# rig-2005 One image, Transfer syntax not supported by IDS" > rig-2005.txt
perl ../../iig/rad69_requests/gen_one_study.pl $communityE /opt/xdsi/storage/rig/E/CASCE2011-1/images ids >> rig-2005.txt

# 2006, One Image, Unknown DICOM UIDs
echo "# rig-2006 One image, Unknown DICOM UIDs" > rig-2006.txt
perl ../../iig/rad69_requests/gen_one_study_with_suffix.pl $communityE /opt/xdsi/storage/rig/E/CASCE2011-1/images .999 ids >> rig-2006.txt

# 2007, One Image, Unregistered IDS
echo "# rig-2007 One image, Unregistered IDS " > rig-2007.txt
perl ../../iig/rad69_requests/gen_one_study.pl $communityZ /opt/xdsi/storage/rig/E/CASCE2011-1/images ids >> rig-2007.txt

# 2008, Partial Success, Single IDS
echo "# rig-2008 Partial Success, Single IDS" > rig-2008.txt
perl ../../iig/rad69_requests/gen_one_study.pl $communityE /opt/xdsi/storage/rig/E/CASCE2011-1/images ids >> rig-2008.txt
echo "#" >> rig-2008.txt
echo "# The next SOP Instance UID is unknown to the destination" >> rig-2008.txt
perl ../../iig/rad69_requests/gen_one_study_with_suffix.pl $communityE /opt/xdsi/storage/rig/E/CASCE2011-1/images .999 omit >> rig-2008.txt

# Now, turn to Community F

# 2011, MR Study, One Community
echo "# rig-2011 MR Study, one responding gateway" > rig-2011.txt
perl ../../iig/rad69_requests/gen_one_study.pl $communityF /opt/xdsi/storage/rig/F/CASCF2021/images ids >> rig-2011.txt

# The following requests are for combined E/F

# 2021, One CR image in E, one CR image in F
echo "# rig-2021 One CR image in E, one CR image in F" > rig-2021.txt
echo "# CR image, data set E" >> rig-2021.txt
perl ../../iig/rad69_requests/gen_one_study.pl $communityE /opt/xdsi/storage/rig/E/CASCE3041-1/images ids >> rig-2021.txt
echo "#" >> rig-2021.txt
echo "# CR image, data set F" >> rig-2021.txt
perl ../../iig/rad69_requests/gen_one_study.pl $communityF /opt/xdsi/storage/rig/F/CASCF3041-2/images ids >> rig-2021.txt

# 2022, One CR image in E, Error image in F
echo "# rig-2022 One CR image in E, error image in F" > rig-2022.txt
echo "# CR image, data set E" >> rig-2022.txt
perl ../../iig/rad69_requests/gen_one_study.pl $communityE /opt/xdsi/storage/rig/E/CASCE3041-1/images ids >> rig-2022.txt
echo "#" >> rig-2022.txt
echo "# error image, data set F" >> rig-2022.txt
perl ../../iig/rad69_requests/gen_one_study_with_suffix.pl $communityF /opt/xdsi/storage/rig/F/CASCF3041-2/images .999 ids >> rig-2022.txt

##- # 1022, One CR image in A, Error Study in B
##- echo "# iig-1022 One CR image in A, Error study in B" > iig-1022.txt
##- echo "# CR image, community A" >> iig-1022.txt
##- perl gen_one_study.pl $communityA /opt/xdsi/storage/iig/A/CASCA1011-1/images >> iig-1022.txt
##- echo "#" >> iig-1022.txt
##- echo "# One image, Unknown DICOM UIDs" >> iig-1022.txt
##- perl gen_one_study_with_suffix.pl $communityA /opt/xdsi/storage/iig/A/CASCA1011-1/images .999 >> iig-1022.txt

if ($1 == "X") then
 foreach i (2001 2002 2003 2004 2005 2006 2007 2008 2011 2021)
  if (! -e ../rig-$i) mkdir ../rig-$i
  mv rig-$i.txt ../rig-$i
 end

endif
