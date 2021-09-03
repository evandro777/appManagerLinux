#!/bin/bash
#######################
##### ROOT ACCESS #####
#######################
if [ $EUID != "0" ]; then
	echo "Must be run as root!" 1>&2
	#exit 1
	if [ -t 1 ]; then
		exec sudo -- "$0" "$@"
	else
		exec gksudo -- "$0" "$@"
	fi
fi
#FOLLOW SYMLINK / USE SCRIPT DIRECTORY
cd "$(dirname "$(realpath "$0")")"

#COLORS
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

url_download=$(curl -sL "http://www.nomachine.com/download/download&id=1" | grep -o "https://download.nomachine.com/download.*deb")

echo -e "file to download:"
echo -e "${ORANGE}${url_download}${NC}"

read -p "Pressione [Enter] para continuar."

filename=$(echo "${url_download}" | rev | cut -d/ -f1 | rev)
downloaded_file="/tmp/${filename}"

wget "$url_download" -O "$downloaded_file"

sudo dpkg -i $downloaded_file