#!/bin/sh

export TEST=iig-1007
export BASE=/opt/xdsi/results/acme/$TEST

echo summary $TEST
echo No RAD-75 validation
echo ""

echo $BASE/RAD-69/reports/summary.txt
cat  $BASE/RAD-69/reports/summary.txt
echo ""
