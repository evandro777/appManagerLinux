#!/bin/bash
#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color
echo -e "${ORANGE}Installing FFmpeg${NC}"

apt update

#Install 
sudo apt install -y ffmpeg
