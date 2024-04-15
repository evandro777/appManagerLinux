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

echo "Installing virtual Box (free version)"
sudo apt-get install -y -q virtualbox virtualbox-dkms virtualbox-qt

echo "Auto disabling services"
sudo systemctl disable virtualbox.service
sudo systemctl disable virtualbox-guest-utils.service

printf '
Manual start
	sudo systemctl start virtualbox.service
	sudo systemctl start virtualbox-guest-utils.service'
