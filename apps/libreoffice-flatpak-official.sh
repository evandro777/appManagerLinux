#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Libreoffice - Official Flatpak${NC}"

flatpak install --system -y flathub org.libreoffice.LibreOffice

echo -e "${ORANGE}Libreoffice > Force setting dark mode [flatpak bug: https://github.com/flathub/org.libreoffice.LibreOffice/issues/130]${NC}"
flatpak override --user --env=GTK_THEME=Mint-Y-Dark org.libreoffice.LibreOffice
