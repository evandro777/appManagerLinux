#!/bin/bash

readonly APPLICATION_NAME="Mint Cinnamon > Settings > Startup > Others [Modem, Postfix]"

function perform_install() {
    echo "Startup > Enable > Others > ModemManager: this only matters for USB or built-in mobile modems."
    sudo systemctl enable --now ModemManager.service

    echo "Startup > Enable > Others > Postfix: this only matters for mail servers."
    sudo systemctl enable --now postfix.service
}

function perform_uninstall() {
    echo "Startup > Disable > Others > ModemManager: this only matters for USB or built-in mobile modems."
    sudo systemctl disable --now ModemManager.service

    echo "Startup > Disable > Others > Postfix: this only matters for mail servers."
    sudo systemctl disable --now postfix.service
}

function perform_check() {
    package_is_installed=0
    if systemctl is-enabled --quiet ModemManager.service \
        && systemctl is-enabled --quiet postfix.service; then
        package_is_installed=1
    fi
    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/mint-cinnamon-helper.sh" # Include file
. "$DIR/../../includes/header_packages.sh"

exit 0
