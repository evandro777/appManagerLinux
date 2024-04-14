#!/bin/bash

readonly APPLICATION_NAME="Flatseal (Manage Flatpak permissions) [official Flatpak]"
readonly APPLICATION_ID="com.github.tchx84.Flatseal"

function perform_install() {
    flatpak_install --system "$APPLICATION_ID"
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
