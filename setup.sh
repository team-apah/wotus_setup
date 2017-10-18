#!/bin/bash

DEST='/srv/http'
DEST_USER='http'
dudo=('sudo' "--user=$DEST_USER")

# Download Map and Cahokia
git clone https://github.com/team-apah/map
git clone https://github.com/team-apah/cahokia

# Prep map
cd map
git checkout cahokia # TODO: Remove when cahokia is merged into master
rm -fr doc .git test .gitignore .gitmodules package.json README.md .travis.yml

# Prep cahokia
cd ../cahokia
rm -fr .git .gitignore README.md doc

# Download Geoserver
wget 'https://sourceforge.net/projects/geoserver/files/GeoServer/2.11.2/geoserver-2.11.2-bin.zip' -P /tmp
unzip /tmp/geoserver-2.11.2-bin.zip -d /tmp
rm -fr /tmp/geoserver-2.11.2-bin.zip
mv /tmp/geoserver-2.11.2 geoserver

# Run and setup Geoserver
./geoserver_script run &> geoserver.log &
GS_PID=$!
echo 'WAITING 30 SECONDS FOR GEOSERVER TO GET SET UP'
sleep 30
./geoserver_script setup
echo 'SETUP GEOSERVER, NOW WAITING FOR GEOSERVER EXIT'
sleep 5
kill $GS_PID
wait $GS_PID
cd ..

# Copy Results to destination
sudo mv map/* $DEST
rmdir map
sudo mv cahokia $DEST
sudo cp .htaccess $DEST
sudo chown -R $DEST_USER:$DEST_USER $DEST

echo 'DONE'
