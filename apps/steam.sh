#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color
echo -e "${ORANGE}Installing Steam${NC}"

sudo apt-get install -y steam-installer
steam
