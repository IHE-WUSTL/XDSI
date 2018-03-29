#!/bin/csh

set A=/opt/xdsi/storage/ids-dataset-E
touch $A; rm -r $A; mkdir $A

perl ../common/create_ids_files_with_compression.pl /opt/xdsi/storage/rig/E /opt/xdsi/storage/ids-dataset-E
if ($status != 0) then
 echo  Dataset E failed
 exit
endif

set B=/opt/xdsi/storage/ids-dataset-F
touch $B; rm -r $B; mkdir $B
perl ../common/create_ids_files_with_compression.pl /opt/xdsi/storage/rig/F /opt/xdsi/storage/ids-dataset-F
