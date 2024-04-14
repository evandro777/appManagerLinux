#!/bin/bash

readonly APPLICATION_NAME="OpenRGB - RGB lighting control [unofficial Flatpak]"
readonly APPLICATION_ID="org.openrgb.OpenRGB"

function perform_install() {
    flatpak_install --system "$APPLICATION_ID"
    echo "Enabling device permissions openrgb udev..."
    bash <(curl -s https://openrgb.org/releases/release_0.9/openrgb-udev-install.sh)
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
