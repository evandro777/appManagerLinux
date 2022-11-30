#!/bin/bash

if [[ $SUDO_USER ]]; then
	#AVOID USING EVAL: USER_HOME=$(eval echo ~${SUDO_USER})
	USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
else
	USER_HOME=$HOME
fi

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Dropbox (Distro ppa)${NC}"

sudo apt install -y dropbox

if [ "$DESKTOP_SESSION" == "cinnamon" ]; then
    sudo apt install -y nemo-dropbox
	
	#ADD SHORTCUT (BOOKMARKS) TO NEMO
	printf "\nfile://${USER_HOME}/Dropbox Dropbox" >> ~/.config/gtk-3.0/bookmarks
	#printf "\nfile://${USER_HOME}/Dropbox/documments/SO/Linux Linux" >> ~/.config/gtk-3.0/bookmarks
#else
#    if $DESKTOP_SESSION = "mate"; then
#        ./linux_mint_18.1_mate.sh
#    fi
fi


#Give Write permission to dropbox folder (usefull for some applications like apache access files on this folder) > A PASTA SÓ É CRIADA APÓS USAR A PRIMEIRA VEZ, ENTAO FOI COMENTADO, POIS A PASTA NESTE MOMENTO NAO EXISTE
#sudo chmod 755 ~/Dropbox/

#DROPBOX > DISABLE AUTOSTART
#dropbox autostart n
#DROPBOX > CUSTOM AUTOSTART WITH DELAY (AVOID PROBLEMS WITH TRAY ICON): THE FILENAME MUST BE DIFFERENT THAN dropbox.desktop, OR DROPBOX WILL REWRITE IT
#printf '[Desktop Entry]
#Type=Application
#Exec=bash -c "sleep 7 && dropbox stop && nice -n 19 ionice -c 3 -n 7 dropbox start -i"
#NoDisplay=false
#Hidden=false
#Name[en_US]=Dropbox
#Comment[en_US]=Custom autostart for Dropbox
#Icon=dropbox
#X-GNOME-Autostart-Delay=0
#X-GNOME-Autostart-enabled=true' > ~/.config/autostart/my_dropbox.desktop
