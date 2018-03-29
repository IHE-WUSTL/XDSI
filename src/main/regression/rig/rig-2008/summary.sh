#!/bin/sh

export TEST=rig-2008
export BASE=/opt/xdsi/results/apex/$TEST

echo summary $TEST
echo $BASE/RAD-69/reports/summary.txt
ls -l $BASE/RAD-69/reports/summary.txt
cat  $BASE/RAD-69/reports/summary.txt
echo ""

echo $BASE/RAD-75/reports/summary.txt
ls -l $BASE/RAD-75/reports/summary.txt
cat  $BASE/RAD-75/reports/summary.txt
echo ""
