#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Flameshot [distro repository +custom config]"
readonly APPLICATION_ID="flameshot"

function perform_install() {
    package_install "$APPLICATION_ID"

    flameShotIniPath="${HOME}/.config/flameshot/"
    mkdir -p "${flameShotIniPath}"

    flameShotIniFile="${flameShotIniPath}flameshot.ini"
    touch "${flameShotIniFile}"

    echo -e "${ORANGE}Flameshot > Disable welcome message${NC}"
    crudini --set "${flameShotIniFile}" General showStartupLaunchMessage "false"

    if [ "$DESKTOP_SESSION" == "cinnamon" ]; then
        echo -e "${ORANGE}Flameshot > Applying shortcut: Super + Print Screen${NC}"

        set_new_keybinding "Flameshot" "flameshot gui" "'<Super>Print'"
    fi
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
   if [ "$DESKTOP_SESSION" == "cinnamon" ]; then
        remove_keybinding "Flameshot" "flameshot gui"
   fi
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
