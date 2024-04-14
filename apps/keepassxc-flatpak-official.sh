#!/bin/bash

readonly APPLICATION_NAME="KeePassXC [official Flatpak]"
readonly APPLICATION_ID="org.keepassxc.KeePassXC"

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
