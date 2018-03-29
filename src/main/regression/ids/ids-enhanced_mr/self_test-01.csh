#!/bin/csh

# This self-test script runs the -01 script to create and submit
# data to our simulator.


if ($1 == "X") then
 set FOLDER=$XDSI/tests/ids/ids-enhanced_mr
else
 set FOLDER=../../../tests/ids/ids-enhanced_mr
 setenv PERL5LIB ../../../tests/common
endif

perl $FOLDER/ids-enhanced_mr-01.pl DCM4CHEE-local

