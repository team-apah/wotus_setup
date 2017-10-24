#!/bin/bash

INSTALL=${INSTALL:-false}
DEST=${DEST:-'/srv/http'}
DEST_USER=${DEST_USER:-'http'}
dudo=('sudo' "--user=$DEST_USER")

# Download and prep map
if [ ! -d map ]
then
    git clone https://github.com/team-apah/map
    cd map
    git checkout cahokia # TODO: Remove when cahokia is merged into master
    rm -fr doc .git test .gitignore .gitmodules package.json README.md .travis.yml
    cd ..
fi

# Download and Prep cahokia
if [ ! -d cahokia ]
then
    git clone https://github.com/team-apah/cahokia
    cd cahokia
    rm -fr .git .gitignore README.md doc
    cd ..
fi

if [ ! -d cahokia/geoserver ]
then
    # Download Geoserver
    rm -fr /tmp/geo*
    if ! wget 'https://sourceforge.net/projects/geoserver/files/GeoServer/2.11.2/geoserver-2.11.2-bin.zip' -P /tmp
    then
        echo 'Could not download Geoserver'
        exit 1
    fi
    if ! unzip /tmp/geoserver-2.11.2-bin.zip -d /tmp
    then
        echo 'Could not unzip Geoserver'
        exit 1
    fi
    rm -fr /tmp/geoserver-2.11.2-bin.zip
    mv /tmp/geoserver-2.11.2 cahokia/geoserver

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
    cd ../..
fi

if $INSTALL
then
    # Copy Results to destination
    sudo cp -r map/* $DEST
    sudo cp -r cahokia $DEST
    sudo cp .htaccess $DEST
    sudo chown -R $DEST_USER:$DEST_USER $DEST
fi

echo 'DONE'
