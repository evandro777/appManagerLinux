#!/bin/bash

readonly APPLICATION_NAME="Smile (emoji picker) [official Flatpak]"
readonly APPLICATION_ID="it.mijorus.smile"

function perform_install() {
    flatpak_install "$APPLICATION_ID"

    # Not automatically pasting bug: https://github.com/mijorus/smile/issues/78
    if [ "$DESKTOP_SESSION" == "cinnamon" ]; then
        echo -e "${YELLOW}Smile Applying shortcut: SUPER + .${NC}"
        set_new_keybinding "Smile" "flatpak run it.mijorus.smile" "'<Super>period'"
    fi
}

function perform_uninstall() {
    flatpak_uninstall "$APPLICATION_ID"
    if [ "$DESKTOP_SESSION" == "cinnamon" ]; then
        remove_keybinding "Smile" "flatpak run it.mijorus.smile"
    fi
}

function perform_check() {
    flatpak_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
