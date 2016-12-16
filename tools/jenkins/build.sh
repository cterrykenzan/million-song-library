#!/bin/bash
echo $BUILD_NUMBER > $WORKSPACE/build_number
cd $WORKSPACE;

echo "****"
echo "****"
echo "****"
echo "looking for localhost"
grep -R 127.0.0.1 *
grep -R localhost *
echo "****"
echo "****"
echo "****"

sed -i -e 's/domain=127.0.0.1/domain=$CASSANDRA_HOST/' $WORKSPACE/server/msl-catalog-data-client/src/main/resources/config.properties
sed -i -e 's/domain=127.0.0.1/domain=$CASSANDRA_HOST/' $WORKSPACE/server/msl-account-data-client/src/main/resources/config.properties
for file in `grep -Rl "local=\"127.0.0.1\"" *`; do sed -i -e "s/local=\"127.0.0.1\"/local=\"$CASSANDRA_HOST\"/g" -e 's/us-west-2/$AWS_REGION/g' $file; done

#Service .poms expect to package RPMs with individualized installer names
# Should generalize when time allows.
echo "Configuring Installation Script"
INSTALLER_FILENAME=`echo $SERVICE_NAME | sed -e s/msl/install/`
cp tools/rpm/postinstall.sh server/$SERVICE_NAME/$INSTALLER_FILENAME.sh
sed -i -e s/=EDITME/=$SERVICE_NAME/ server/$SERVICE_NAME/$INSTALLER_FILENAME.sh
cat server/$SERVICE_NAME/$INSTALLER_FILENAME.sh

echo "Setting default cluster to the msl monolith elb"
for file in `grep -Rl "DEFAULT_CLUSTER = \"127.0.0.1\"" *`; do sed -i -e "s/DEFAULT_CLUSTER\ =\ \"127.0.0.1\"/DEFAULT_CLUSTER\ =\ \"$CASSANDRA_HOST\"/g" -e 's/us-west-2/$AWS_REGION/g' $file; done
grep -R DEFAULT_CLUSTER *

#Installing --all-- of the msl requirements, even frontend.
# Makes builds come out consistently.
# Can cut down build duration when time allows for refining this.
cd $WORKSPACE/msl-pages;
npm install -y
bower install
npm run generate-swagger-html
npm install webpack
npm install -y protractor
npm install -y selenium-webdriver

cd $WORKSPACE
for file in `grep -Rl "DEFAULT_CLUSTER = \"127.0.0.1\"" *`; do sed -i -e "s/DEFAULT_CLUSTER\ =\ \"127.0.0.1\"/DEFAULT_CLUSTER\ =\ \"$CASSANDRA_HOST\"/g" -e 's/us-west-2/$AWS_REGION/g' $file; done
echo "Double checking"
grep -R DEFAULT_CLUSTER *

#The extra build steps seem superfluous but work consistently.
#Same as above - refine when time allows.
cd $WORKSPACE/msl-pages
npm run build-server
cd $WORKSPACE/server/$SERVICE_NAME;
mvn compile
mvn package -P rpm-package

mkdir $WORKSPACE/RPM/
cp $WORKSPACE/server/$SERVICE_NAME/target/rpm/$SERVICE_NAME/RPMS/x86_64/$SERVICE_NAME*.rpm $WORKSPACE/RPM/
