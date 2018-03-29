#!/bin/csh

# Full patient ID: AD201512170905042^^^&1.3.6.1.4.1.21367.2005.13.20.1000&ISO
# Self test for valiadation.

if ($1 == "X") then
 set FOLDER=$XDSI/tests/ids/ids-single-image
else
 set FOLDER=../../../tests/ids/ids-single-image
 setenv PERL5LIB ../../../tests/common
endif


perl $FOLDER/ids-single-image-03.pl xdsi01__rep-reg  DEPT201512191241034 AD201512170905042
