#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Chrome - Official PPA${NC}"

wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor --yes -o /etc/apt/keyrings/chrome.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list'
sudo apt-get update
sudo apt-get install -y google-chrome-stable
#BETA: sudo apt-get install -y google-chrome-beta
#UNSTABLE: sudo apt-get install -y google-chrome-unstable

echo -e "Chrome > After install > Removing duplicate source entry"
sudo rm /etc/apt/sources.list.d/google-chrome.list &>/dev/null
