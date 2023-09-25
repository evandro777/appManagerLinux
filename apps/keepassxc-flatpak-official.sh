#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing KeePassXC - Official Flatpak${NC}"

flatpak install --user -y flathub org.keepassxc.KeePassXC
