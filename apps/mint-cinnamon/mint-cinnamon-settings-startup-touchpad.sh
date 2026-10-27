#!/bin/bash

readonly APPLICATION_NAME="Mint Cinnamon > Settings > Startup > Touchpad gestures"

function perform_install() {
    echo "Startup > Enable > Touchpad gestures"
    startup_enable_app "touchegg.desktop"
    sudo systemctl enable --now touchegg.service
}

function perform_uninstall() {
    echo "Startup > Disable > Touchpad gestures"
    startup_disable_app "touchegg.desktop"
    sudo systemctl disable --now touchegg.service
}

function perform_check() {
    package_is_installed=0
    if [ "$(startup_is_enable_app touchegg.desktop)" == "true" ]; then
        package_is_installed=1
    fi
    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/mint-cinnamon-helper.sh" # Include file
. "$DIR/../../includes/header_packages.sh"

exit 0
