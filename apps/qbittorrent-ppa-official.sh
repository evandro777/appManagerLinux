#!/bin/bash

#QBittorrent > OFFICIAL
#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing QBittorrent - Official PPA${NC}"

sudo add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable
sudo apt-get install -y qbittorrent
