#!/bin/csh

set A=/opt/xdsi/storage/ids-community-A
set B=/opt/xdsi/storage/ids-community-B
touch $A; rm -r $A; mkdir $A
touch $B; rm -r $B; mkdir $B

perl ../common/create_ids_files_with_compression.pl /opt/xdsi/storage/iig/A /opt/xdsi/storage/ids-community-A
if ($status != 0) then
 echo  Community A failed
 exit
endif

perl ../common/create_ids_files_with_compression.pl /opt/xdsi/storage/iig/B /opt/xdsi/storage/ids-community-B
