#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Variety - Official PPA${NC}"

sudo add-apt-repository -y ppa:variety/stable

#Variety (Wallpaper) > DO NOT USE --install-suggests --install-recommends IT WILL INSTALL ABOUT 1GB OF FILES
sudo apt install -y variety
