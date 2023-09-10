#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Strawberry - Official PPA${NC}"

sudo add-apt-repository -y ppa:jonaski/strawberry

sudo apt install -y strawberry
