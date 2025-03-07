#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Chrome [official repository]"
#stable: google-chrome-stable, beta: google-chrome-beta, unstable: google-chrome-unstable
readonly APPLICATION_ID="google-chrome-stable"
readonly APPLICATION_KEYRING=/etc/apt/keyrings/chrome.gpg
readonly APPLICATION_SOURCE_LIST=/etc/apt/sources.list.d/google.list

function perform_install() {
    wget -q -O - "https://dl.google.com/linux/linux_signing_key.pub" | sudo gpg --dearmor --yes -o "$APPLICATION_KEYRING"
    sudo sh -c 'echo "deb [arch=amd64 signed-by='$APPLICATION_KEYRING'] http://dl.google.com/linux/chrome/deb/ stable main" > '$APPLICATION_SOURCE_LIST
    package_update
    package_install "$APPLICATION_ID"
    echo -e "Chrome > After install > Removing duplicate source entry"
    sudo rm /etc/apt/sources.list.d/google-chrome.list &> /dev/null
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
