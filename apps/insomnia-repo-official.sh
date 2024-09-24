#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Insomnia [official repository]"
readonly APPLICATION_ID="insomnia"
readonly APPLICATION_KEYRING=/usr/share/keyrings/kong-insomnia-archive-keyring.gpg
readonly APPLICATION_SOURCE_LIST=/etc/apt/sources.list.d/kong-insomnia.list

function perform_install() {
    echo "${RED}At 2024-09-11 for Ubuntu 24 or Mint 22, this *official* install script isn't working!${NC}"
    # Official install instructions: https://docs.insomnia.rest/insomnia/install
    curl -1sLf 'https://packages.konghq.com/public/insomnia/setup.deb.sh' | sudo -E bash
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
