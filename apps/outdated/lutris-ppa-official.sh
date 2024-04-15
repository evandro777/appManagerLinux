#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Lutris - Official PPA${NC}"

sudo add-apt-repository ppa:lutris-team/lutris
sudo apt-get update
sudo apt-get install -y -q lutris

#NVIDIA
#sudo add-apt-repository ppa:graphics-drivers/ppa
#sudo dpkg --add-architecture i386
#sudo apt-get update

#sudo apt-get install -y -q nvidia-driver-430 libnvidia-gl-430 libnvidia-gl-430:i386

#Install libvulkan
#sudo apt-get install -y -q libvulkan1 libvulkan1:i386
