#!/bin/csh

set XDSI=/opt/xdsi
set TOMCAT_BASE=tomcat/apache-tomcat-7.0.65-xdstools2-01
set TEST_DIR=runDirectory/tests/RAD-68/ProvideAndRegister
set WEB_DIR=webapps/xdstools2/toolkitx/testkit/testdata-repository/RAD-68

set SRC=$XDSI/$TEST_DIR
set DST=$XDSI/$TOMCAT_BASE/$WEB_DIR

mkdir --verbose --parents $DST

rm --verbose $DST/*

cp --verbose $SRC/*.dcm $DST
cp --verbose $SRC/*.xml $DST

ls -l $DST