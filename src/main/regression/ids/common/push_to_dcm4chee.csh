#!/bin/csh

set ROOT=/opt/xdsi/storage/ids/c

foreach patient($ROOT/*)
 echo $patient
  storescu -c DCM4CHEE@localhost:11112 $patient/images
  if ($status != 0) then
   echo "Could not send: $patient"
   exit
  endif
end

