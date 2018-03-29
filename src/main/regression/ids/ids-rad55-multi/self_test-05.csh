#!/bin/csh

# Full patient ID: AD201601131258015^^^&1.3.6.1.4.1.21367.2005.13.20.1000&ISO
# Dept ID: DEPT201601131258015
# Self test for validation


if ($1 == "X") then
 set FOLDER=$XDSI/tests/ids/ids-rad55-multi
else
 set FOLDER=../../../tests/ids/ids-rad55-multi
 setenv PERL5LIB ../../../tests/common
endif

perl $FOLDER/ids-rad55-multi-05.pl DEPT201601131258015 AD201601131258015 https://localhost:8080/wado xdsi01__rep-reg 
