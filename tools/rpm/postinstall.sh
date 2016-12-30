#!/bin/bash

echo "Environment variables I can use:"
export

#Using INSTALLING_SERVICE rather than SERVICE_NAME because
# when this script runs, Jenkins is out of the picture and can't pass in vars
INSTALLING_SERVICE=EDITME
echo "Service to install: $INSTALLING_SERVICE"
INSTALLING_CASSANDRA=EDITCASSANDRA
echo "Cassandra Host is at: $INSTALLING_CASSANDRA"

if [ $INSTALLING_SERVICE == EDITME ]; then
  echo "Script was supposed to be edited by jenkins job first."
  exit 1
fi

chmod a+rwx /var/log/msl
JAR_TO_EXEC=`find /opt/kenzan/$INSTALLING_SERVICE-*-with-dependencies.jar`

cd /tmp/
if unzip $JAR_TO_EXEC config.properties; then
  #sed -i -e s/127.0.0.1/$INSTALLING_CASSANDRA/ config.properties
  #cat /tmp/config.properties
  echo "domain=$INSTALLING_CASSANDRA" > config.properties
  echo "keyspace=msl" >> config.properties
  echo "region=us-east-1" >> config.properties
  zip -f $JAR_TO_EXEC config.properties
else
  echo "Editing config failed during jar unpack, reason:"
  unzip $JAR_TO_EXEC config.properties
  exit 1
fi

if [ `echo $JAR_TO_EXEC | wc -l` == 1 ]; then
  echo "Found $JAR_TO_EXEC"
  echo "Adding startup line to rc.local" | tee -a /tmp/msl-install.log
  echo "/usr/bin/java8 -jar $JAR_TO_EXEC 2>&1 | tee -a /var/log/msl/$INSTALLING_SERVICE.log" | tee -a /tmp/msl-install.log | tee /opt/kenzan/startup.sh
  chmod +x /opt/kenzan/startup.sh > /dev/null
  echo "/usr/bin/screen -dmS $INSTALLING_SERVICE /opt/kenzan/startup.sh" | tee -a /etc/rc.local
else
  echo "Wrong number of $INSTALLING_SERVICE jars found in /opt/kenzan/" | tee -a /tmp/msl-install.log
  exit 1
fi
