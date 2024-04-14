#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Strawberry Music Player [official PPA]"
readonly APPLICATION_ID="strawberry"
readonly APPLICATION_PPA="ppa:jonaski/strawberry"

function perform_install() {
    sudo add-apt-repository -y $APPLICATION_PPA
    package_update
    package_install "$APPLICATION_ID"
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
    sudo add-apt-repository --remove $APPLICATION_PPA
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
