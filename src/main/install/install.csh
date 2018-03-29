#!/bin/csh

set XDSI=/opt/xdsi

if (! -e $XDSI) then
 mkdir $XDSI 
endif


touch $XDSI/tests
rm -r $XDSI/tests
cp -rp ../tests /opt/xdsi

touch $XDSI/lib
rm -r $XDSI/lib
mkdir $XDSI/lib
cp ../../../target/ERL-IHE-XDSI-jar-with-dependencies.jar $XDSI/lib/ERL-IHE-XDSI.jar

if (! -e $XDSI/bin) mkdir $XDSI/bin
cp ../bin-scripts/* $XDSI/bin
chmod +x $XDSI/bin/*

touch $XDSI/runDirectory
rm -r $XDSI/runDirectory
mkdir $XDSI/runDirectory

cp -rp ../resources/runDirectory/* /opt/xdsi/runDirectory

#chgrp -R staff $XDSI

