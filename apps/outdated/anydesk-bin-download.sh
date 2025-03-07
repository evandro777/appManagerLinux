#!/bin/bash

#COLORS
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

downloaded_file="/tmp/anydesk.deb"
echo -e "${ORANGE}Visit AnyDesk website to get download url: https://anydesk.com/download?os=linux${NC}"

echo -e "${ORANGE}Paste the url to download the file${NC}"
echo -e "Ex.: https://download.anydesk.com/linux/anydesk_4.0.1-1_amd64.deb"
read -p "" url_download
wget "$url_download" -O "$downloaded_file"

#EXECUTE PERMISSION
sudo chmod +x "${downloaded_file}"

#EXECUTE INSTALL
echo -e "${ORANGE}Installing${NC}"
sudo dpkg -i  "${downloaded_file}"
sudo apt-get install -f -y -q
