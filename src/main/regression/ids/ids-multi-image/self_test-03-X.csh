#!/bin/csh

# Self test for the validation script (03).
# The Department ID references a study for a different patient
# This is to simulate someone who sends the wrong KOS.

if ($1 == "X") then
 set FOLDER=$XDSI/tests/ids/ids-multi-image
else
 set FOLDER=../../../tests/ids/ids-multi-image
 setenv PERL5LIB ../../../tests/common
endif

# Full patient ID: AD201512211322011^^^&1.3.6.1.4.1.21367.2005.13.20.1000&ISO

perl $FOLDER/ids-multi-image-03.pl xdsi01__rep-reg DEPT201512211322011 AD201512211350042

