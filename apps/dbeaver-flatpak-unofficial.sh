#!/bin/bash

readonly APPLICATION_NAME="Dbeaver [unofficial Flatpak]"
readonly APPLICATION_ID="io.dbeaver.DBeaverCommunity"

function perform_install() {
    flatpak_install "$APPLICATION_ID"
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
