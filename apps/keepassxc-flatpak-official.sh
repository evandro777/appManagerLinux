#!/bin/bash

readonly APPLICATION_NAME="KeePassXC [official Flatpak]"
readonly APPLICATION_ID="org.keepassxc.KeePassXC"
readonly APPLICATION_PROP_PATH="${HOME}/.var/app/org.keepassxc.KeePassXC/config/keepassxc"
readonly APPLICATION_PROP_FILE="${APPLICATION_PROP_PATH}/keepassxc.ini"

function perform_install() {
    flatpak_install "$APPLICATION_ID"

    # Check if the file exists
    if [ ! -f "$APPLICATION_PROP_FILE" ]; then
        echo "Creating default (customized) properties"

        # Ensure that the directory exists
        mkdir -p "$APPLICATION_PROP_PATH"

        # Create the file if it doesn't exist
        touch "$APPLICATION_PROP_FILE"

        # Create "default" properties
        {
            echo "[General]"
            echo "ConfigVersion=2"
            echo ""
            echo "[PasswordGenerator]"
            echo 'AdditionalChars=".,:;\\|/_-<*+!?={[()]}"'
            echo "AdvancedMode=true"
            echo "ExcludedChars="
            echo "Length=12"
            echo "Logograms=false"
            echo ""
            echo "[Security]"
            echo "IconDownloadFallback=true"
        } > "$APPLICATION_PROP_FILE"
    fi
}

function perform_uninstall() {
    flatpak_uninstall "$APPLICATION_ID"
}

function perform_check() {
    flatpak_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
