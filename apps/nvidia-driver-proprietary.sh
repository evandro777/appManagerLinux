#!/bin/bash

#COLORS
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${ORANGE}Installing Nvidia - Official + Unofficial patches${NC}"

sudo apt-get install -y nvidia-settings

echo -e "${ORANGE}Installing API VAAPI (Video Acceleration API) + API VDPAU (Video Decode and Presentation API for Unix)${NC}"
sudo apt-get install -y va-driver-all vdpau-driver-all libvdpau-va-gl1

echo -e "${ORANGE}Applying Nvidia Driver Patches: https://github.com/keylase/nvidia-patch/${NC}"

PATCH_TEMP_FOLDER="/tmp/nvidia-patch"

git clone --depth=1 https://github.com/keylase/nvidia-patch.git "${PATCH_TEMP_FOLDER}"

echo "NVENC patch removes restriction on maximum number of simultaneous NVENC video encoding sessions imposed by Nvidia to consumer-grade GPUs."
sudo bash "${PATCH_TEMP_FOLDER}"/patch.sh
sudo bash "${PATCH_TEMP_FOLDER}"/patch.sh -f

echo "NvFBC patch allows to use NvFBC on consumer-grade GPUs"
sudo bash "${PATCH_TEMP_FOLDER}"/patch-fbc.sh
sudo bash "${PATCH_TEMP_FOLDER}"/patch-fbc.sh -f
