#!/bin/csh

set XDSI=/opt/xdsi
set JAVA=/opt/xdsi/java/jdk1.8.0_65

set XDSTOOLS201=$XDSI/tomcat/apache-tomcat-7.0.65-xdstools2-01

if (! -e $JAVA) then
 echo JAVA "Should be installed as $JAVA"
 exit
endif

if (! -e $XDSTOOLS201) then
 echo "You should have already unzipped tomcat in $XDSI/tomcat and renamed"
 echo " the folder to $XDSTOOLS201"
 exit
endif

cp ../config/xds/01/server.xml $XDSTOOLS201/conf

cp ../config/xds/setenv.sh $XDSTOOLS201/bin
chmod +x $XDSTOOLS201/bin/*.sh
ls -l $XDSTOOLS201/bin/setenv.sh

if (! -e $XDSTOOLS201/webapps/xdstools2.war) then
 echo "You need to copy xdstools2.war in $XDSTOOLS201/webapps."
 echo "After you copy the war file, you need to start and then stop tomcat."
 exit
endif

if (! -e $XDSTOOLS201/webapps/xdstools2) then
 echo "You need to start tomcat to expand the xdstools2 war file."
 echo "Then, you need to stop tomcat and run this script again to finish installation."
 exit
endif

cp ../config/xds/01/toolkit.properties $XDSTOOLS201/webapps/xdstools2/WEB-INF

mkdir -p $XDSI/xds-toolkit/01
cp -rp ../config/xds/01/external-cache/actors       $XDSI/xds-toolkit/01
cp -rp ../config/xds/01/external-cache/environment  $XDSI/xds-toolkit/01
cp -rp ../config/xds/01/external-cache/simdb        $XDSI/xds-toolkit/01
cp -rp ../config/xds/01/external-cache/TestLogCache $XDSI/xds-toolkit/01

pushd ../other/testdata-repository
foreach i (*)
 echo $i
 touch $XDSTOOLS201/webapps/xdstools2/toolkitx/testkit/testdata-repository/$i
 rm -r $XDSTOOLS201/webapps/xdstools2/toolkitx/testkit/testdata-repository/$i
 cp -r $i $XDSTOOLS201/webapps/xdstools2/toolkitx/testkit/testdata-repository
end
popd
