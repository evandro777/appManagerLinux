#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Chrome - Official PPA${NC}"

wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list'
apt update
sudo apt install -y google-chrome-stable
#BETA: sudo apt install -y google-chrome-beta
#UNSTABLE: sudo apt install -y google-chrome-unstable
#After install, remove duplicate source entry
sudo rm /etc/apt/sources.list.d/google-chrome.list &>/dev/null
