#!/bin/bash

#COLORS
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

echo -e "${ORANGE}Installing Discord (Third party Flatpak)${NC}"

flatpak install -y flathub com.discordapp.Discord

echo -e "${BOLD}Game Activity:${NORMAL} This flatpak version of Discord cannot scan running processes to detect running games. There is currently no workaround or solution for this limitation."

echo -e "Default sandbox permissions for this package limit Discord to only certain directories, so you can't access your entire Home directory. Currently, this limits which file directories you can attach files from and impacts drag and drop functionality."
echo -e "To work around this now, you can change sandbox permissions of installed flatpak applications to give Discord broader file system access, allowing file attachments from more locations."
sudo flatpak override --filesystem=home com.discordapp.Discord
