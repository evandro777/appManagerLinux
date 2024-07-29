#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Libreoffice [official PPA]"
readonly APPLICATION_ID="libreoffice"
readonly APPLICATION_PPA="ppa:libreoffice/ppa"

function perform_install() {
    sudo add-apt-repository -y "$APPLICATION_PPA"
    package_update
    package_install "$APPLICATION_ID"
}

function perform_uninstall() {
    sudo apt-get purge -y "$APPLICATION_ID*"
    sudo apt-get autoremove -y
    sudo add-apt-repository --remove "$APPLICATION_PPA"
}

function perform_check() {
    package_is_installed=$(package_is_installed "$APPLICATION_ID")
    if [ "$package_is_installed" -eq 0 ]; then
        package_is_installed=$(package_is_installed "libreoffice-core")
    fi
    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
