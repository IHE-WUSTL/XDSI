#!/bin/csh

# This self-test script executes a dry-run.
# In the dry-run, we are looking for files in the repository with the proper
# identifiers but not actually performing validation.


if ($1 == "X") then
 set FOLDER=$XDSI/tests/ids/ids-rad16-single
else
 set FOLDER=../../../tests/ids/ids-rad16-single
 setenv PERL5LIB ../../../tests/common
endif

# Full patient ID: AD201601051438004^^^&1.3.6.1.4.1.21367.2005.13.20.1000&ISO

perl $FOLDER/ids-rad16-single-02.pl xdsi01__rep-reg  DEPT201601051438004 AD201601051438004

