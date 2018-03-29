#!/bin/csh

# This self-test script executes a dry-run.
# In the dry-run, we are looking for files in the repository with the proper
# identifiers but not actually performing validation.


if ($1 == "X") then
else
 setenv PERL5LIB ../../../tests/common
endif

# Full patient ID: IDCAD012^^^&1.3.6.1.4.1.21367.2005.13.20.1000&ISO

perl IDCAD012-02.pl xdsi01__rep-reg  IDCDEPT012 IDCAD012
