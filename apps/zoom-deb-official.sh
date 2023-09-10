#!/bin/bash

#COLORS
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${ORANGE}Installing Zoom - Official Deb${NC}"

# Script from: https://askubuntu.com/questions/1271154/updating-zoom-in-the-terminal

url=https://zoom.us/client/latest/zoom_amd64.deb
debdir=/usr/local/zoomdebs
aptconf=/etc/apt/apt.conf.d/100update_zoom
sourcelist=/etc/apt/sources.list.d/zoomdebs.list

sudo mkdir -p $debdir
( echo 'APT::Update::Pre-Invoke {"cd '$debdir' && wget -qN '$url' && apt-ftparchive packages . > Packages && apt-ftparchive release . > Release";};' | sudo tee $aptconf
    echo 'deb [trusted=yes lang=none] file:'$debdir' ./' | sudo tee $sourcelist
) >/dev/null

sudo apt update
sudo apt install -y zoom
