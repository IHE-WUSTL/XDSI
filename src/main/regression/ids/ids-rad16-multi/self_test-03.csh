#!/bin/csh

# Full patient ID: AD201601131258015^^^&1.3.6.1.4.1.21367.2005.13.20.1000&ISO
# Dept ID: DEPT201601131258015

# This is a self-test of the C-Move request we send to the Imaging Document Source.


if ($1 == "X") then
 set FOLDER=$XDSI/tests/ids/ids-rad16-multi
else
 set FOLDER=../../../tests/ids/ids-rad16-multi
 setenv PERL5LIB ../../../tests/common
endif


perl $FOLDER/ids-rad16-multi-03.pl DEPT201601131258015 AD201601131258015 DCM4CHEE-local xdsi01__rep-reg 

