#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Windows Extra Fonts (needed for WPS Office)${NC}"

tmpWindowsFontsFolder="/tmp/windows-fonts/"
wget --no-verbose --timestamping --directory-prefix="${tmpWindowsFontsFolder}" "https://github.com/dv-anomaly/ttf-wps-fonts/archive/master.zip"
unzip -o "${tmpWindowsFontsFolder}master.zip" -d "${tmpWindowsFontsFolder}"
sudo "${tmpWindowsFontsFolder}ttf-wps-fonts-master/"./install.sh
