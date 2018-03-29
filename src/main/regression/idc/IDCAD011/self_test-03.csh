#!/bin/csh

# Full patient ID: IDCAD011^^^&1.3.6.1.4.1.21367.2005.13.20.1000&ISO
# This sends a WADO retrieve to the Imaging Document Source simulator.
# This simulates the Imaging Document Consumer.

if ($1 == "X") then
else
 setenv PERL5LIB ../../../tests/common
endif


setenv IDS_PORT 8080
setenv IDS_PORT_PROXY 10800
setenv IDS_WADO_PORT ${IDS_PORT_PROXY}

perl IDCAD011-03.pl IDCDEPT011 IDCAD011 http://localhost:${IDS_WADO_PORT}/wado xdsi01__rep-reg

