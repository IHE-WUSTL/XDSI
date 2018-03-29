#!/bin/sh

export TEST=iig-1005
export BASE=/opt/xdsi/results/acme/$TEST

echo summary $TEST
echo $BASE/RAD-75/reports/summary.txt
cat  $BASE/RAD-75/reports/summary.txt
echo ""

echo $BASE/RAD-69/reports/summary.txt
cat  $BASE/RAD-69/reports/summary.txt
echo ""
