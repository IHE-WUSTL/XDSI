#!/bin/csh

# Full patient ID: AD201601051438004^^^&1.3.6.1.4.1.21367.2005.13.20.1000&ISO
# This is a self-test of the RAD55/WADO request we send to the Imaging Document Source.


if ($1 == "X") then
 set FOLDER=$XDSI/tests/ids/ids-rad55-single
else
 set FOLDER=../../../tests/ids/ids-rad55-single
 setenv PERL5LIB ../../../tests/common
endif


perl $FOLDER/ids-rad55-single-03.pl DEPT201601051438004 AD201601051438004 http://localhost:8080/wado xdsi01__rep-reg 

