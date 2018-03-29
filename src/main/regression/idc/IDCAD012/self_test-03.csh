#!/bin/csh

# Full patient ID: IDCAD012^^^&1.3.6.1.4.1.21367.2005.13.20.1000&ISO
# This sends a WADO retrieve to the Imaging Document Source simulator.
# This simulates the Imaging Document Consumer.

if ($1 == "X") then
else
 setenv PERL5LIB ../../../tests/common
endif


perl IDCAD012-03.pl IDCDEPT012 IDCAD012 DCM4CHEE-local xdsi01__rep-reg

