#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Clementine - Official PPA${NC}"

sudo apt-add-repository -y ppa:me-davidsansome/clementine

#DO NOT USE --install-suggests --install-recommends IT WILL INSTALL ABOUT 1GB OF FILES
sudo apt-get install -y clementine
