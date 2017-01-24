#!/bin/bash
echo $BUILD_NUMBER > $WORKSPACE/build_number
cd $WORKSPACE;

#Service .poms expect to package RPMs with individualized installer names
# Should generalize when time allows.
#RPM plugin currently grabs script from the service working dir
# Can get the two-for-one deal by referencing the install script directly once it's refactored
echo "Configuring Installation Script"
INSTALLER_FILENAME=`echo $SERVICE_NAME | sed -e s/msl/install/`
cp $WORKSPACE/tools/rpm/postinstall.sh $WORKSPACE/server/$SERVICE_NAME/$INSTALLER_FILENAME.sh
cat $WORKSPACE/server/$SERVICE_NAME/$INSTALLER_FILENAME.sh

#Installing all msl requirements so this script can remain generalized.
cd $WORKSPACE/msl-pages;
npm install -y
bower install
npm run generate-swagger-html
npm install webpack
npm install -y protractor
npm install -y selenium-webdriver

#The extra build steps seem superfluous but work consistently.
#Same as above - refine when time allows.
cd $WORKSPACE/msl-pages
npm run build-server


cd $WORKSPACE/server/$SERVICE_NAME;
#mvn compile
mvn package -P rpm-package

mkdir $WORKSPACE/RPM/
BUILD_NUMBER=`cat $WORKSPACE/build_number`
cp $WORKSPACE/server/$SERVICE_NAME/target/rpm/$SERVICE_NAME/RPMS/x86_64/$SERVICE_NAME*.rpm $WORKSPACE/RPM/
