#!/bin/bash

#Official PPA
#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing KeePassXC - Official PPA${NC}"

sudo add-apt-repository -y ppa:phoerious/keepassxc
sudo apt install -y keepassxc
