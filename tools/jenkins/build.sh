#!/bin/bash
echo $BUILD_NUMBER > $WORKSPACE/build_number
cd $WORKSPACE;

$CASSANDRA_HOST="cassandra-msl.$BASE_DOMAIN"

echo "Cassandra is at $CASSANDRA_HOST"

for file in `grep -Rl "local=127.0.0.1" *`; do
  sed -i -e s/local=127.0.0.1/domain=$CASSANDRA_HOST/g -e 's/us-west-2/$AWS_REGION/g' $file;
done
for file in `grep -Rl "domain=127.0.0.1" *`; do
  sed -i -e s/domain=127.0.0.1/domain=$CASSANDRA_HOST/g -e 's/us-west-2/$AWS_REGION/g' $file;
done
echo "Setting default cluster to the msl monolith elb"
for file in `grep -Rl "127.0.0.1" *`; do
  sed -i -e "s/127.0.0.1/$CASSANDRA_HOST/g" -e 's/us-west-2/$AWS_REGION/g' $file;
done

#Service .poms expect to package RPMs with individualized installer names
# Should generalize when time allows.
#RPM plugin currently grabs script from the service working dir
# Can get the two-for-one deal by referencing the install script directly once it's refactored
echo "Configuring Installation Script"
INSTALLER_FILENAME=`echo $SERVICE_NAME | sed -e s/msl/install/`
cp $WORKSPACE/tools/rpm/postinstall.sh $WORKSPACE/server/$SERVICE_NAME/$INSTALLER_FILENAME.sh
sed -i -e s/=EDITME/=$SERVICE_NAME/ $WORKSPACE/server/$SERVICE_NAME/$INSTALLER_FILENAME.sh
cat $WORKSPACE/server/$SERVICE_NAME/$INSTALLER_FILENAME.sh

echo "Setting default cluster to the msl monolith elb"
for file in `grep -Rl "127.0.0.1" *`; do
  sed -i -e "s/127.0.0.1/$CASSANDRA_HOST/g" -e 's/us-west-2/$AWS_REGION/g' $file;
done

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

cd $WORKSPACE
for file in `grep -Rl "local=127.0.0.1" *`; do
  sed -i -e s/local=127.0.0.1/domain=$CASSANDRA_HOST/g -e 's/us-west-2/$AWS_REGION/g' $file;
done
for file in `grep -Rl "domain=127.0.0.1" *`; do
  sed -i -e s/domain=127.0.0.1/domain=$CASSANDRA_HOST/g -e 's/us-west-2/$AWS_REGION/g' $file;
done
echo "Setting default cluster to the msl monolith elb"
for file in `grep -Rl "127.0.0.1" *`; do
  sed -i -e "s/127.0.0.1/$CASSANDRA_HOST/g" -e 's/us-west-2/$AWS_REGION/g' $file;
done

cd $WORKSPACE/server/$SERVICE_NAME;
#mvn compile
mvn package -P rpm-package


echo "Double checking"
grep -R DEFAULT_CLUSTER *
find . -type f | grep config$ | xargs cat | grep domain
find . -type f | grep config$ | xargs cat | grep local

mkdir $WORKSPACE/RPM/
BUILD_NUMBER=`cat $WORKSPACE/build_number`
cp $WORKSPACE/server/$SERVICE_NAME/target/rpm/$SERVICE_NAME/RPMS/x86_64/$SERVICE_NAME*.rpm $WORKSPACE/RPM/
