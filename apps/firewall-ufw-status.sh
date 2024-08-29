#!/bin/bash

readonly APPLICATION_NAME="Firewall UFW status (enable|disable)"

function perform_install() {
    echo -e "${YELLOW}Enabling $APPLICATION_NAME...${NC}"
    sudo ufw enable
    sudo ufw status verbose
}

function perform_uninstall() {
    echo -e "${RED}Disabling $APPLICATION_NAME...${NC}"
    sudo ufw disable
}

function perform_check() {
    if sudo ufw status | grep -q inactive; then
        echo 0 # Firewall is disabled
    else
        echo 1 # Firewall is enabled
    fi
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
