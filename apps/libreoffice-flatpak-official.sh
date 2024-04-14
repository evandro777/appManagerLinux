#!/bin/bash

readonly APPLICATION_NAME="Libreoffice [official Flatpak]"
readonly APPLICATION_ID="org.libreoffice.LibreOffice"

function perform_install() {
    flatpak_install --system "$APPLICATION_ID"

    echo -e "${YELLOW}Libreoffice > Force setting dark mode [flatpak bug: https://github.com/flathub/org.libreoffice.LibreOffice/issues/130]${NC}"
    flatpak override --user --env=GTK_THEME=Mint-Y-Dark org.libreoffice.LibreOffice
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
