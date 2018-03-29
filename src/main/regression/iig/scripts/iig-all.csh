#!/bin/csh

set LOG=/tmp/iig-summary.txt
touch $LOG
rm    $LOG
echo IIG `date` > $LOG
echo "" >> $LOG

foreach i (iig-1*)
 echo $i
 $i/selftest-10.sh
 $i/selftest-11.sh
 $i/summary.sh >> $LOG
end
