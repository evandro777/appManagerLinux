#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Libreoffice - Official Flatpak${NC}"

flatpak install --system -y flathub org.libreoffice.LibreOffice
