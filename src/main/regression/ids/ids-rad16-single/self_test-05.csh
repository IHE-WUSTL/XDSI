#!/bin/csh

# Full patient ID: AD201601051438004^^^&1.3.6.1.4.1.21367.2005.13.20.1000&ISO
# Self test for validation


if ($1 == "X") then
 set FOLDER=$XDSI/tests/ids/ids-rad16-single
else
 set FOLDER=../../../tests/ids/ids-rad16-single
 setenv PERL5LIB ../../../tests/common
endif

perl $FOLDER/ids-rad16-single-05.pl DEPT201601051438004 AD201601051438004 DCM4CHEE-local xdsi01__rep-reg 

