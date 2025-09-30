#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Syncthing [official repository]"
readonly APPLICATION_ID="syncthing"
readonly APPLICATION_KEYRING=/etc/apt/keyrings/syncthing-archive-keyring.gpg
readonly APPLICATION_SOURCE_LIST=/etc/apt/sources.list.d/syncthing.list
readonly SYNCTHING_SYNC_FOLDER_ROOT="$HOME/Syncthing"
readonly SYNCTHING_SYNC_FOLDER_DEFAULT="$SYNCTHING_SYNC_FOLDER_ROOT/Default"
readonly SYNCTHING_CONFIG_DIR="$HOME/.local/state/syncthing"
readonly SYNCTHING_CONFIG_FILE="$SYNCTHING_CONFIG_DIR/config.xml"

function perform_install() {
    curl -sS https://syncthing.net/release-key.gpg | sudo gpg --dearmor --yes -o "$APPLICATION_KEYRING"
    echo "deb [signed-by=$APPLICATION_KEYRING] https://apt.syncthing.net/ syncthing stable" | sudo tee "$APPLICATION_SOURCE_LIST"
    package_update
    package_install "$APPLICATION_ID"

    change_default_shared_folder

    if command -v ufw &> /dev/null; then
        echo "UFW firewall detected. Creating exception rules"
        sudo ufw allow 22000/tcp comment 'Syncthing: All'
        sudo ufw allow 21027/udp comment 'Syncthing: All'
        echo "Showing UFW created rules"
        sudo ufw status | grep "Syncthing: All"
    fi

    echo "Start Syncthing & enable autostart"
    systemctl --user enable syncthing.service
    systemctl --user start syncthing.service
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
    sudo rm "$APPLICATION_SOURCE_LIST"
    sudo rm "$APPLICATION_KEYRING"

    if command -v ufw &> /dev/null; then
        echo "UFW firewall detected. Removing exception rules"
        sudo ufw status numbered | grep "Syncthing: All" | awk -F'[][]' '{print $2}' | sort -nr | while read -r rule; do
            yes | sudo ufw delete "$rule"
        done
    fi
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

function change_default_shared_folder() {
    mkdir -p "$SYNCTHING_SYNC_FOLDER_DEFAULT"
    mv "$HOME/Sync" "$SYNCTHING_SYNC_FOLDER_DEFAULT"

    if [ ! -f "$SYNCTHING_CONFIG_FILE" ]; then
        echo "Creating Syncthing config file..."
        syncthing generate
    fi

    # Edit config.xml > change defaults folder
    sed -i "s|<folder id=\"default\" label=\"Default Folder\" path=\"[^\"]*\"|<folder id=\"default\" label=\"Default Folder\" path=\"$SYNCTHING_SYNC_FOLDER_DEFAULT\"|" "$SYNCTHING_CONFIG_FILE"
    sed -i "s|<folder id=\"\" label=\"\" path=\"~*\"|<folder id=\"\" label=\"\" path=\"$SYNCTHING_SYNC_FOLDER_ROOT\"|" "$SYNCTHING_CONFIG_FILE"

    echo "Set sharing icon for ${SYNCTHING_SYNC_FOLDER_ROOT}"
    gio set "${SYNCTHING_SYNC_FOLDER_ROOT}" metadata::custom-icon-name syncthing
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
