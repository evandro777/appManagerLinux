#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing OnlyOffice - Official Flatpak${NC}"

flatpak install -y flathub org.onlyoffice.desktopeditors

