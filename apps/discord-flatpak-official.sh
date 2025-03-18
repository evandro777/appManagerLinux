#!/bin/bash

readonly APPLICATION_NAME="Discord [official Flatpak]"
readonly APPLICATION_ID="com.discordapp.Discord"

function perform_install() {
    flatpak_install "$APPLICATION_ID"

    echo -e "${RED}Game Activity:${NC} This flatpak version of Discord cannot scan running processes to detect running games. There is currently no workaround or solution for this limitation."
    echo -e "Default sandbox permissions for this package limit Discord to only certain directories, so you can't access your entire Home directory. Currently, this limits which file directories you can attach files from and impacts drag and drop functionality."
    echo -e "To work around this now, you can change sandbox permissions of installed flatpak applications to give Discord broader file system access, allowing file attachments from more locations."
    # sudo flatpak override --filesystem=home "$APPLICATION_ID"
    flatpak override --user --filesystem=home "$APPLICATION_ID"
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
