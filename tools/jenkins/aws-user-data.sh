#!/bin/bash
#2017 Kenzan Media, LLC
#This puts a basic configuration into the service instances upon launch.
#Feed this into a Base64 encoder and paste the output into the Spinnaker deploy stages' UserData advanced option.
#Not required for msl-pages
BASE_DOMAIN=msl.example.com
INSTALLING_CASSANDRA=cassandra-msl.$BASE_DOMAIN

SERVICE_JAR=`find /opt/kenzan/msl-*-with-dependencies.jar`
echo "Found a jar at $SERVICE_JAR"

cd /tmp/
mv config.properties config.properties-prev
if unzip $SERVICE_JAR config.properties; then
  #chmod a+rw config.properties
  #sed -i -e s/127.0.0.1/$INSTALLING_CASSANDRA/ config.properties
  rm -rf config.properties
  echo "creating config"
  echo "domain=$INSTALLING_CASSANDRA" > config.properties
  echo "keyspace=msl" >> config.properties
  echo "region=us-east-1" >> config.properties
  cat config.properties
  echo "adding to zip"
  zip -f $SERVICE_JAR config.properties
else
  echo "Editing config failed during jar unpack, reason:"
  unzip $SERVICE_JAR config.properties
  exit 1
fi
