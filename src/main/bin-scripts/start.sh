#!/bin/sh

/opt/xdsi/tomcat/apache-tomcat-7.0.65-xdstools2-01/bin/startup.sh

mkdir -p /opt/xdsi/storage/storageSCP
/opt/xdsi/dcm4che/dcm4che-3.3.7/bin/storescp --directory /opt/xdsi/storage/storageSCP --filepath {00100020}/{00080018}.dcm --bind SIMSTORAGESCP:3000 &

clear