#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Insync (Official repository)${NC}"

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ACCAF35C
#echo deb http://apt.insync.io/ubuntu xenial non-free contrib | sudo tee /etc/apt/sources.list.d/insync.list
echo deb http://apt.insync.io/mint $(lsb_release --codename --short) non-free contrib | sudo tee /etc/apt/sources.list.d/insync.list
sudo apt-get update
sudo apt-get install -y insync

