#!/bin/sh

export TEST=rig-2007
export BASE=/opt/xdsi/results/apex/$TEST

echo summary $TEST
echo There is no RAD-69 retrieve for this test
echo ""

echo $BASE/RAD-75/reports/summary.txt
ls -l $BASE/RAD-75/reports/summary.txt
cat  $BASE/RAD-75/reports/summary.txt
echo ""
