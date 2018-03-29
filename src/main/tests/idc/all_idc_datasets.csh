#!/bin/csh

foreach x (a b c z)
 echo $x
 time perl create_data_set_idc.pl $x
 time perl create_kos_and_metadata.pl $x
 time perl ../common/create_ids_repository_files.pl /opt/xdsi/storage/idc/$x /opt/xdsi/storage/ids-repository
end
