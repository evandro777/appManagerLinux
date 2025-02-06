#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="CopyQ [official PPA]"
readonly APPLICATION_ID="copyq"
readonly APPLICATION_PPA="ppa:hluk/copyq"

function perform_install() {
    sudo add-apt-repository -y $APPLICATION_PPA
    package_update
    package_install "$APPLICATION_ID"

    echo "Enable CopyQ autostart"
    copyq --start-server config autostart true > /dev/null

    if [ "$DESKTOP_SESSION" == "cinnamon" ]; then
        echo -e "${YELLOW}CopyQ Applying shortcut: SUPER + v${NC}"
        echo -e "${YELLOW}CopyQ Applying shortcut: CTRL + ALT + v${NC}"
        set_new_keybinding "CopyQ" "copyq menu" "'<Primary><Alt>v', '<Super>v'"
    fi

}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
    sudo add-apt-repository --remove $APPLICATION_PPA
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
