#!/bin/bash

# COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Snap Store (Canonical)${NC}"

sudo rm /etc/apt/preferences.d/nosnap.pref
apt update
sudo apt install -y snapd

