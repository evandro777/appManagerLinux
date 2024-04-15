#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Insync (Official repository)${NC}"

sudo gpg --keyserver keyserver.ubuntu.com --recv-keys ACCAF35C
sudo gpg --export ACCAF35C | sudo tee /usr/share/keyrings/insync-keyring.gpg > /dev/null

# Add the repository with the correct format
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/insync-keyring.gpg] http://apt.insync.io/mint $(lsb_release --codename --short) non-free contrib" | sudo tee /etc/apt/sources.list.d/insync.list

sudo apt-get update
sudo apt-get install -y -q insync
