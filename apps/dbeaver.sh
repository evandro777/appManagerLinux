#!/bin/bash

#COLORS
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${ORANGE}Installing DBeaver${NC}"

#dbeaver Official PPA
sudo add-apt-repository -y ppa:serge-rider/dbeaver-ce
sudo apt-get update
sudo apt install -y dbeaver-ce
 
echo -e "${ORANGE}May have problem with dark themes\n${NC}"

echo -e "${ORANGE}Manually execute: GTK2_RC_FILES=/usr/share/themes/Redmond/gtk-2.0/gtkrc dbeaver\n${NC}"

while true; do
	echo -e "${ORANGE}Do you want to force a light (white) theme on app menu shortcut? (Y/N)${NC}"
	read -p "" dh
	case $dh in
		[Yy]* )
			#sed -i 's/Exec=\/usr\/share\/dbeaver\/dbeaver/Exec=env GTK2_RC_FILES=\/usr\/share\/themes\/Redmond\/gtk-2.0\/gtkrc \/usr\/share\/dbeaver\/dbeaver/g' "${HOME}/.local/share/applications/dbeaver.desktop"
			#sed -i 's/Exec=\/usr\/share\/dbeaver\/dbeaver/Exec=env GTK2_RC_FILES=\/usr\/share\/themes\/Redmond\/gtk-2.0\/gtkrc \/usr\/share\/dbeaver\/dbeaver/g' "/usr/share/applications/dbeaver.desktop"
			sudo sed -i 's/Exec=\/usr\/share\/dbeaver\/dbeaver/Exec=env GTK_THEME=Adwaita:light \/usr\/share\/dbeaver\/dbeaver/g' "/usr/share/applications/dbeaver.desktop"
			sudo sed -i 's/Exec=\/usr\/share\/dbeaver\/dbeaver/Exec=env GTK_THEME=Adwaita:light \/usr\/share\/dbeaver\/dbeaver/g' "$HOME/.local/share/applications/dbeaver.desktop"
			
		break;;
		[Nn]* ) break;;
		* ) break;;
	esac
done

read -p "Press [Enter] to continue."
