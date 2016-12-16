#!/bin/bash

VERSION=$(grep '<msl-server.version>' $WORKSPACE/server/$SERVICE_NAME/pom.xml |sed 's/<[^<>]*>//g'|tr -d ' ')
BUILD_NUMBER=`cat $WORKSPACE/build_number`
NEXUS_USER=
NEXUS_PASS=

mkdir -p $WORKSPACE/tmp
cd $WORKSPACE/tmp

#Sending to temp nexus2 install because yum isn't implemented in 3 yet.

echo "Build number is $BUILD_NUMBER"
curl \
  --upload-file $WORKSPACE/server/$SERVICE_NAME/target/rpm/$SERVICE_NAME/RPMS/x86_64/$SERVICE_NAME*.x86_64.rpm \
  -u $AUTH_UPLOAD \
  -v http://nexus2.kenzan-devops.com/nexus/content/repositories/releases/msl/server/$SERVICE_NAME/$SERVICE_NAME-$BUILD_NUMBER-$RELEASE_TYPE.x86_64.rpm

