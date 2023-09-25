#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Lutris - Official Flatpak${NC}"

flatpak install --user -y flathub net.lutris.Lutris
