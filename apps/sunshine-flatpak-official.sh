#!/bin/bash

readonly APPLICATION_NAME="Sunshine [official Flatpak]"
readonly APPLICATION_ID="dev.lizardbyte.app.Sunshine"

function perform_install() {
    flatpak_install "$APPLICATION_ID"

    if command -v ufw &> /dev/null; then
        echo "UFW firewall detected. Creating exception rules"
        sudo ufw allow 47984/tcp comment 'Sunshine: All'
        sudo ufw allow 47989/tcp comment 'Sunshine: All'
        sudo ufw allow 47990/tcp comment 'Sunshine: All'
        sudo ufw allow 48010/tcp comment 'Sunshine: All'
        sudo ufw allow 47998:48000/udp comment 'Sunshine: All'
        echo "Showing UFW created rules"
        sudo ufw status | grep "Sunshine: All"
    fi

    echo -e "${RED}First login${NC} access https://localhost:47990/"
    echo -e "${RED}user:${NC} sunshine"
    echo -e "${RED}password:${NC} sunshine"

    echo -e "${RED}To add steam as an application, use this as command:${NC} flatpak-spawn --host /usr/games/steam -gamepadui"
    
}

function perform_uninstall() {
    flatpak_uninstall "$APPLICATION_ID"

    if command -v ufw &> /dev/null; then
        echo "UFW firewall detected. Removing exception rules"
        sudo ufw status numbered | grep "Sunshine: All" | awk -F'[][]' '{print $2}' | sort -nr | while read -r rule; do
          yes | sudo ufw delete "$rule"
        done
    fi
}

function perform_check() {
    flatpak_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
