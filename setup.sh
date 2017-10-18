#!/bin/bash

set -e

DEST='/srv/http'
DEST_USER='http'

# Get and prep map
git clone https://github.com/team-apah/map
cd map
git checkout cahokia # TODO: Remove when cahokia is merged into master
rm -fr doc .git test .gitignore .gitmodules package.json README.md .travis.yml

# Get and prep cahokia
git clone https://github.com/team-apah/cahokia
cd ../cahokia
rm -fr .git .gitignore README.md doc

