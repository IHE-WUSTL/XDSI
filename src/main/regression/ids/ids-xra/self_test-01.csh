#!/bin/csh

# This self-test script runs the -01 script to create and submit
# data to our simulator.


if ($1 == "X") then
 set FOLDER=$XDSI/tests/ids/ids-xra
else
 set FOLDER=../../../tests/ids/ids-xra
 setenv PERL5LIB ../../../tests/common
endif

perl $FOLDER/ids-xra-01.pl DCM4CHEE-local

