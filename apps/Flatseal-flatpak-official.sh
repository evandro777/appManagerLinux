#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Flatseal (Manage Flatpak permissions) - Official Flatpak${NC}"

flatpak install --system -y flathub com.github.tchx84.Flatseal
