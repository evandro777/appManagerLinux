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

#Alternative with SNAP
#sudo snap install insomnia

#INSTALL WITH APTs
# Add to sources
sudo sh -c 'echo "deb https://dl.bintray.com/getinsomnia/Insomnia /" > /etc/apt/sources.list.d/insomnia.list'

# Add public key used to verify code signature
wget --quiet -O - https://insomnia.rest/keys/debian-public.key.asc | sudo apt-key add -

# Refresh repository sources and install Insomnia
sudo apt update
sudo apt install -y insomnia