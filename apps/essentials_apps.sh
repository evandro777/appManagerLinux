#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/essentials.sh"
. "../includes/root_restrict_but_sudo.sh"

echo -e "${YELLOW}Installing Essentials Apps${NC}"

echo -e "${YELLOW}Installing Conky${NC}"
sudo apt-get install -y -q conky conky-all
#allow regular user to execute hddtemp without needing sudo (to get temperatures for conky)
sudo chmod +s /usr/sbin/hddtemp

echo -e "${YELLOW}Installing Indicator CPU Frequency${NC}"
sudo apt-get install -y -q indicator-cpufreq

echo -e "${YELLOW}Installing Microsoft fonts${NC}"
# Auto set yes to license
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
sudo apt-get install -y -q ttf-mscorefonts-installer

echo -e "${YELLOW}Installing Crudini (manipulate .ini files)${NC}"
sudo apt-get install -y -q crudini

#MANIPULATE OPENED WINDOWS (ALREADY HAVE ON UBUNTU 18+)
#sudo apt-get install -y -q wmctrl

echo -e "${YELLOW}Installing jq (manipulate .js json files)${NC}"
sudo apt-get install -y -q jq

echo -e "${YELLOW}Installing 7ZIP Lib (use in file-roller)${NC}"
sudo apt-get install -y -q p7zip-full

echo -e "${YELLOW}Installing Unrar Lib (use in file-roller)${NC}"
sudo apt-get install -y -q unrar

echo -e "${YELLOW}Installing PIGZ [parallel implementation of gzip]. pigz takes advantage of both multiple CPUs and multiple CPU cores for higher compression and decompression speed${NC}"
sudo apt-get install -y -q pigz

echo -e "${YELLOW}Installing icoutils (.exe resource extractor, usefull for some automated install scripts)${NC}"
sudo apt-get install -y -q icoutils

echo -e "${YELLOW}Installing gnome settings${NC}"
sudo apt-get install -y -q dconf-editor

echo -e "${YELLOW}Installing mint meta (media) codecs${NC}"
sudo apt-get install -y -q mint-meta-codecs

echo -e "${YELLOW}Installing .heic images support${NC}"
sudo apt-get install -y -q heif-gdk-pixbuf

echo -e "${YELLOW}Installing FFmpeg${NC}"
sudo apt-get install -y -q ffmpeg

echo -e "${YELLOW}Installing GIT${NC}"
sudo apt-get install -y -q git

echo -e "${YELLOW}Installing numlockx > Enabling numlock on startup${NC}"
sudo apt-get install -y -q numlockx

echo -e "${YELLOW}Installing API VA-API (Video Acceleration API) and VDPAU -> VA-API translator${NC}"
sudo apt-get install -y -q va-driver-all libvdpau-va-gl1

# echo -e "${YELLOW}Installing Os Query${NC}"
# ./osquery.sh

############################
##### AUTOMATIC SCRIPT #####
############################
FILE_SYSCTL=/etc/sysctl.conf

#CHECK IF vm.swappiness IS SET
#echo -e "${RED}Decrease swap usage to 10 (default: 60)${NC}"
#if ! grep -q "vm.swappiness=10" "${FILE_SYSCTL}"; then
#	sudo sh -c "echo '\n# Decrease swap usage to a more reasonable level' >> ${FILE_SYSCTL}"
#	sudo sh -c "echo 'vm.swappiness=10' >> ${FILE_SYSCTL}"
#	echo -e changing value temporary (until reboot)
#	sudo sysctl vm.swappiness=10
#fi

echo -e "${YELLOW}Increasing limit to monitor files in a directory${NC}"
if ! grep -q "fs.inotify.max_user_watches" "${FILE_SYSCTL}"; then # Check if not already set
    sudo sh -c "echo '# Increase limit to monitor files in a directory' >> ${FILE_SYSCTL}"
    sudo sh -c "echo 'fs.inotify.max_user_watches=524288' >> ${FILE_SYSCTL}"
fi

echo -e "${YELLOW}Increasing vm.max_map_count${NC}"
echo 'Having the default vm.max_map_count size limit of 65530 maps can be too little for some games. Increasing to 2147483642'
printf "vm.max_map_count = 2147483642" | sudo tee /etc/sysctl.d/80-gamecompatibility.conf > /dev/null

sudo sysctl --system

echo -e "${GREEN}Show timestamp in terminal history${NC}"
bashrc="${HOME}/.bashrc"
if ! grep -q "export HISTTIMEFORMAT=" "$bashrc"; then # Check if not already set
    echo "#Show timestamp in history" >> "$bashrc"
    echo 'export HISTTIMEFORMAT="%Y/%m/%d %T "' >> "$bashrc"
    source "$bashrc"
fi

echo -e "${GREEN}Faster startup > GRUB${NC}"
sudo sed -i '/GRUB_TIMEOUT=/ s/10/3/' /etc/default/grub
sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/ s/"quiet splash"/"noplymouth"/' /etc/default/grub
sudo update-grub

echo -e "${GREEN}Faster startup > Disable NetworkManager-wait-online${NC}"
sudo systemctl disable NetworkManager-wait-online.service
