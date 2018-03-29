#!/bin/csh

if ($1 == "") then
 echo "Arguments: actor     idc or ids"
 exit 1
endif

set ACTOR=$1

foreach extension (a b c z)
 echo $extension `date`
 set ROOT=/opt/xdsi/storage/$ACTOR/$extension
 foreach patient($ROOT/*)
  echo $patient
   storescu -c DCM4CHEE@localhost:11112 $patient/images
   if ($status != 0) then
    echo "Could not send: $patient"
    exit
   endif
 end
 echo ""
end
