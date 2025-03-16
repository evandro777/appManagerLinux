#!/bin/bash

readonly APPLICATION_NAME="Firewall UFW status (enable|disable)"

function perform_install() {
    echo -e "${YELLOW}Enabling $APPLICATION_NAME...${NC}"

    if command -v warpinator &> /dev/null; then
        echo "Warpinator detected. Creating exception rules for UFW firewall"

        warpinator_port=$(dconf read /org/x/warpinator/preferences/port)
        warpinator_port=${warpinator_port:-"42000"}

        warpinator_port_reg=$(dconf read /org/x/warpinator/preferences/reg-port)
        warpinator_port_reg=${warpinator_port_reg:-"42001"}

        sudo ufw allow "$warpinator_port" comment 'WARPINATOR_MAIN'
        sudo ufw allow "$warpinator_port_reg"/tcp comment 'WARPINATOR_AUTH'
        sudo ufw allow 5353/udp comment 'WARPINATOR_FLATPAK_ZC_FIX'
        echo "Showing UFW created rules"
        sudo ufw status | grep "WARPINATOR"
    fi

    sudo ufw enable
    sudo ufw status verbose
}

function perform_uninstall() {
    echo -e "${RED}Disabling $APPLICATION_NAME...${NC}"

    if command -v ufw &> /dev/null; then
        echo "Warpinator detected. Removing exception rules"
        sudo ufw status numbered | grep "WARPINATOR" | awk -F'[][]' '{print $2}' | sort -nr | while read -r rule; do
          yes | sudo ufw delete "$rule"
        done
    fi

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
