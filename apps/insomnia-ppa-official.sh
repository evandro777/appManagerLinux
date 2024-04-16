#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Insomnia [official PPA]"
readonly APPLICATION_ID="insomnia"
# KEYRING=/etc/apt/keyrings/chrome.gpg
APPLICATION_SOURCE_LIST=/etc/apt/sources.list.d/insomnia.list

function perform_install() {
    sudo sh -c 'echo "deb [trusted=yes arch=amd64] https://download.konghq.com/insomnia-ubuntu/ default all" > '$APPLICATION_SOURCE_LIST
    package_update
    package_install "$APPLICATION_ID"
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
    sudo rm "$APPLICATION_SOURCE_LIST"
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
