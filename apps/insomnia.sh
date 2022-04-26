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
echo "deb [trusted=yes arch=amd64] https://download.konghq.com/insomnia-ubuntu/ default all" \
    | sudo tee -a /etc/apt/sources.list.d/insomnia.list

# Refresh repository sources and install Insomnia
sudo apt update
sudo apt install -y insomnia

# Used to pause before leaving the execution only when executing from navigators like (nemo)

#GRAND_PARENT_PID=$(ps -ef | awk '{ print $2 " " $3 " " $8 }' | grep -P "^$PPID " | awk '{ print $2 }')
# A SIMPLE FORM:
#GRAND_PARENT_PID=$(ps hoppid $PPID | xargs)
#GRAND_PARENT_NAME=$(ps -ef | awk '{ print $2 " " $3 " " $8 }' | grep -P "^$GRAND_PARENT_PID " | awk '{ print $3 }')

#if [[ "$GRAND_PARENT_NAME" =~ .*"/systemd".* ]]; then
#    read -p "Press any key to continue"
#fi
