#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Steam [distro repository]"
readonly APPLICATION_ID="steam-installer"

function perform_install() {
    package_install "$APPLICATION_ID"
    
    if command -v ufw &> /dev/null; then
        echo "UFW firewall detected. Creating exception rules"
        sudo ufw allow 27000:27015/udp comment 'Steam: All'
        sudo ufw allow 27015:27030/udp comment 'Steam: All'
        sudo ufw allow 27014:27050/tcp comment 'Steam: All'
        sudo ufw allow 4380/udp comment 'Steam: All'
        sudo ufw allow 27015/tcp comment 'Steam: All'
        sudo ufw allow 3478/udp comment 'Steam: All'
        sudo ufw allow 4379/udp comment 'Steam: All'
        sudo ufw allow 27031/udp comment 'Steam: All'
        sudo ufw allow 27036 comment 'Steam: All'
        sudo ufw allow 27037/tcp comment 'Steam: All'
        sudo ufw allow 10400:10401/udp comment 'Steam: All'
        echo "Showing UFW created rules"
        sudo ufw status | grep "Steam: All"
    fi

}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
    
    if command -v ufw &> /dev/null; then
        echo "UFW firewall detected. Removing exception rules"
        sudo ufw status numbered | grep "Steam: All" | awk -F'[][]' '{print $2}' | sort -nr | while read -r rule; do
          yes | sudo ufw delete "$rule"
        done
    fi
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
