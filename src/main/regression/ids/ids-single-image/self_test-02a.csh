#!/bin/csh

# This self-test script executes a dry-run.
# In the dry-run, we are looking for files with the proper
# identifiers but not actually performing validation.

# Full patient ID: AD201512170905042^^^&1.3.6.1.4.1.21367.2005.13.20.1000&ISO

if ($2 == "") then
 echo "Arguments: Departmental_ID AffinityDomain_ID"
 exit 1
endif


set DEPTID=DEPT201512191241034
set ADID=AD201512170905042
set DEPTID=$1
set ADID=$2

if ($3 == "X") then
 set FOLDER=$XDSI/tests/ids/ids-single-image
else
 set FOLDER=../../../tests/ids/ids-single-image
 setenv PERL5LIB ../../../tests/common
endif

perl $FOLDER/ids-single-image-02.pl xdsi01__rep-reg  $DEPTID $ADID
