#!/bin/sh

export TEST=iig-1022
export BASE=/opt/xdsi/results/acme/$TEST

echo summary $TEST

echo $BASE/RAD-75-A/reports/summary.txt
cat  $BASE/RAD-75-A/reports/summary.txt
echo ""

echo $BASE/RAD-75-B/reports/summary.txt
cat  $BASE/RAD-75-B/reports/summary.txt
echo ""

echo $BASE/RAD-69/reports/summary.txt
cat  $BASE/RAD-69/reports/summary.txt
echo ""
