#!/bin/sh

export TEST=rig-2022
export BASE=/opt/xdsi/results/apex/$TEST

echo summary $TEST
echo $BASE/RAD-69-E/reports/summary.txt
ls -l $BASE/RAD-69-E/reports/summary.txt
cat  $BASE/RAD-69-E/reports/summary.txt
echo ""

echo $BASE/RAD-69-F/reports/summary.txt
ls -l $BASE/RAD-69-F/reports/summary.txt
cat  $BASE/RAD-69-F/reports/summary.txt
echo ""

echo $BASE/RAD-75/reports/summary.txt
ls -l $BASE/RAD-75/reports/summary.txt
cat  $BASE/RAD-75/reports/summary.txt
echo ""
