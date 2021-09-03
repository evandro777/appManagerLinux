#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/essentials.sh"
. "../includes/root_restrict_but_sudo.sh"

echo -e "${ORANGE}Installing Essentials apps${NC}"

echo -e "${ORANGE}Installing Conky${NC}"
sudo apt install -y conky conky-all
#allow regular user to execute hddtemp without needing sudo (to get temperatures for conky)
sudo chmod +s /usr/sbin/hddtemp

echo -e "${ORANGE}Installing Indicator CPU Frequency${NC}"
sudo apt install -y indicator-cpufreq

echo -e "${ORANGE}Installing Microsoft fonts${NC}"
sudo ./msfonts.sh

echo -e "${ORANGE}Installing Crudini (manipulate .ini files)${NC}"
sudo apt install -y crudini

#MANIPULATE OPENED WINDOWS (ALREADY HAVE ON UBUNTU 18+)
#sudo apt install -y wmctrl

echo -e "${ORANGE}Installing jq (manipulate .js json files)${NC}"
sudo apt install -y jq

echo -e "${ORANGE}Installing 7ZIP Lib (use in file-roller)${NC}"
sudo apt install -y p7zip-full

echo -e "${ORANGE}Installing Unrar Lib (use in file-roller)${NC}"
sudo apt install -y unrar

echo -e "${ORANGE}Installing PIGZ [parallel implementation of gzip]. pigz takes advantage of both multiple CPUs and multiple CPU cores for higher compression and decompression speed${NC}"
sudo apt install -y pigz

echo -e "${ORANGE}Installing icoutils (.exe resource extractor, usefull for some automated install scripts)${NC}"
sudo apt install -y icoutils

echo -e "${ORANGE}Installing gnome settings${NC}"
sudo apt install -y dconf-editor

echo -e "${ORANGE}Installing samba (access windows network)${NC}"
sudo apt install -y samba

echo -e "${ORANGE}Installing mint meta (media) codecs${NC}"
sudo apt install -y mint-meta-codecs

echo -e "${ORANGE}Installing Os Query${NC}"
./osquery.sh

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

echo -e "${ORANGE}Increasing limit to monitor files in a directory${NC}"
if ! grep -q "fs.inotify.max_user_watches" "${FILE_SYSCTL}"; then
	sudo sh -c "echo '# Increase limit to monitor files in a directory' >> ${FILE_SYSCTL}"
	sudo sh -c "echo 'fs.inotify.max_user_watches=524288' >> ${FILE_SYSCTL}"
fi

sudo sysctl -p

echo -e "${GREEN}Show timestamp in history${NC}"
if ! grep -q "export HISTTIMEFORMAT=" ~/.bashrc; then
	echo "#Show timestamp in history" >> ~/.bashrc
	echo 'export HISTTIMEFORMAT="%Y/%m/%d %T "' >> ~/.bashrc ; source ~/.bashrc
fi

