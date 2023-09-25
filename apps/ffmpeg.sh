#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color
echo -e "${ORANGE}Installing FFmpeg${NC}"

sudo apt-get update

#Install
sudo apt-get install -y ffmpeg
