#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Steam [distro repository]"
readonly APPLICATION_ID="steam-installer"

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
