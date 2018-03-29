#!/bin/csh

# Full patient ID: AD201601131258015^^^&1.3.6.1.4.1.21367.2005.13.20.1000&ISO
# Dept ID: DEPT201601131258015

# This self-test script executes a dry-run.
# In the dry-run, we are looking for files in the repository with the proper
# identifiers but not actually performing validation.


if ($1 == "X") then
 set FOLDER=$XDSI/tests/ids/ids-rad55-multi
else
 set FOLDER=../../../tests/ids/ids-rad55-multi
 setenv PERL5LIB ../../../tests/common
endif

perl $FOLDER/ids-rad55-multi-02.pl xdsi01__rep-reg DEPT201601131258015 AD201601131258015

