#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Spotify [official repository]"
readonly APPLICATION_ID="spotify-client"
readonly APPLICATION_KEYRING=/etc/apt/keyrings/spotify.gpg
readonly APPLICATION_SOURCE_LIST=/etc/apt/sources.list.d/spotify.list

function perform_install() {
    curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o "$APPLICATION_KEYRING"
    echo "deb [signed-by=$APPLICATION_KEYRING] http://repository.spotify.com stable non-free" | sudo tee "$APPLICATION_SOURCE_LIST"
    package_update
    package_install "$APPLICATION_ID"
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
    sudo rm "$APPLICATION_SOURCE_LIST"
    sudo rm "$APPLICATION_KEYRING"
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
