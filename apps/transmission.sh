#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Transmission (torrent client) [distro repository]"
readonly APPLICATION_ID="transmission-gtk"

function perform_install() {
    package_install "$APPLICATION_ID"
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
