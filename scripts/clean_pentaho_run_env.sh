#!/bin/bash
#Cleans out temporary directories used by pentaho.
rm -rf /opt/pentaho/server/biserver-ee/tomcat/work/*
rm -rf /opt/pentaho/server/biserver-ee/tomcat/temp/*
rm -f /opt/pentaho/server/biserver-ee/tomcat/conf/Catalina/localhost/*
rm -rf /opt/pentaho/server/biserver-ee/pentaho-solutions/system/jackrabbit/repository/*
rm -rf /opt/pentaho/server/biserver-ee/pentaho-solutions/system/karaf/data1/cache/*

#Remove lock files
FILE="/opt/pentaho/server/biserver-ee/pentaho-solutions/system/jackrabbit/repository/.lock"
if [ -f $FILE ]; then rm $FILE; fi

#Optionally clear logs
#rm -rf /opt/pentaho/server/biserver-ee/tomcat/logs/*