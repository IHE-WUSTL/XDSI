#!/bin/csh

set LOG=/tmp/rig-summary.txt
touch $LOG
rm    $LOG
echo RIG `date` > $LOG
echo "" >> $LOG

foreach i (rig-2*)
 echo $i
 $i/selftest-10.sh
 $i/selftest-11.sh
 $i/summary.sh >> $LOG
end
