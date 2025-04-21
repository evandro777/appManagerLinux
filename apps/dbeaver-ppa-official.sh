#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="DBeaver [official PPA]"
readonly APPLICATION_ID="dbeaver-ce"
readonly APPLICATION_PPA="ppa:serge-rider/dbeaver-ce"

function perform_install() {
    sudo add-apt-repository -y $APPLICATION_PPA
    package_update
    package_install "$APPLICATION_ID"

    #Older version had problem with dark themes

    #echo -e "${ORANGE}May have problem with dark themes\n${NC}"
    #echo -e "${ORANGE}Manually execute: GTK2_RC_FILES=/usr/share/themes/Redmond/gtk-2.0/gtkrc dbeaver\n${NC}"
    #while true; do
    #	echo -e "${ORANGE}Do you want to force a light (white) theme on app menu shortcut? (Y/N)${NC}"
    #	read -p "" dh
    #	case $dh in
    #		[Yy]* )
    #			#sed -i 's/Exec=\/usr\/share\/dbeaver\/dbeaver/Exec=env GTK2_RC_FILES=\/usr\/share\/themes\/Redmond\/gtk-2.0\/gtkrc \/usr\/share\/dbeaver\/dbeaver/g' "${HOME}/.local/share/applications/dbeaver.desktop"
    #			#sed -i 's/Exec=\/usr\/share\/dbeaver\/dbeaver/Exec=env GTK2_RC_FILES=\/usr\/share\/themes\/Redmond\/gtk-2.0\/gtkrc \/usr\/share\/dbeaver\/dbeaver/g' "/usr/share/applications/dbeaver.desktop"
    #			sudo sed -i 's/Exec=\/usr\/share\/dbeaver\/dbeaver/Exec=env GTK_THEME=Adwaita:light \/usr\/share\/dbeaver\/dbeaver/g' "/usr/share/applications/dbeaver.desktop"
    #			sudo sed -i 's/Exec=\/usr\/share\/dbeaver\/dbeaver/Exec=env GTK_THEME=Adwaita:light \/usr\/share\/dbeaver\/dbeaver/g' "$HOME/.local/share/applications/dbeaver.desktop"
    #
    #		break;;
    #		[Nn]* ) break;;
    #		* ) break;;
    #	esac
    #done
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
    sudo add-apt-repository --remove --yes $APPLICATION_PPA
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
