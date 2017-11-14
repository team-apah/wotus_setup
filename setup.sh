#!/bin/bash

INSTALL=${INSTALL:-false}
PACKAGE=${PACKAGE:-true}
DEST=${DEST:-'/srv/http'}
DEST_USER=${DEST_USER:-'http'}
dudo=('sudo' "--user=$DEST_USER")

GS_URL='http://sourceforge.net/projects/geoserver/files/GeoServer/2.12.0/geoserver-2.12.0-bin.zip'
GS_NAME='geoserver-2.12.0'

rm -fr map map.tar.gz

# Download and prep map
rm -fr map
git clone https://github.com/team-apah/map
cd map
git submodule update --init
cd lib/Leaflet
git checkout v0.7.7
cd ../..
rm -fr doc .git test .gitignore .gitmodules package.json README.md .travis.yml

# Download and Prep cahokia
rm -fr cahokia
git clone https://github.com/team-apah/cahokia
cd cahokia
rm -fr .git .gitignore README.md doc
cd ..

# Download Geoserver
rm -fr /tmp/geo*
if ! wget $GS_URL -P /tmp
then
    echo 'Could not download Geoserver'
    exit 1
fi
if ! unzip /tmp/$GS_NAME-bin.zip -d /tmp
then
    echo 'Could not unzip Geoserver'
    exit 1
fi
rm -fr /tmp/$GS_NAME-bin.zip
mv /tmp/$GS_NAME cahokia/geoserver

# Run and setup Geoserver
cd cahokia/geoserver
java -jar start.jar &> ../../geoserver.server.log &
GS_PID=$!
echo 'WAITING 30 SECONDS FOR GEOSERVER TO GET SET UP'
sleep 30
../bin/geoserver_script setup
SETUP_RV=$?
echo 'SETUP GEOSERVER, NOW WAITING FOR GEOSERVER EXIT'
sleep 5
kill $GS_PID
wait $GS_PID
if [ ! -z $SETUP_RV ]; then
    exit 1
fi
cd ../../..
cp .htaccess map

if $INSTALL
then
    # Copy Results to destination
    sudo cp -r map/* $DEST
    sudo cp -r cahokia $DEST
    sudo cp .htaccess $DEST
    sudo chown -R $DEST_USER:$DEST_USER $DEST
fi

if $PACKAGE
    tar -czf map.tar.gz map
then

fi

echo 'DONE'
