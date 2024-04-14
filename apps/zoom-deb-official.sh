#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Zoom [official Deb > custom update]"
readonly APPLICATION_ID="zoom"
readonly APPLICATION_DEB_DIR="/usr/local/zoomdebs"
readonly APPLICATION_APT_CONF="/etc/apt/apt.conf.d/100update_zoom"
readonly APPLICATION_SOURCE_LIST="/etc/apt/sources.list.d/zoomdebs.list"

function perform_install() {
    # Script from: https://askubuntu.com/questions/1271154/updating-zoom-in-the-terminal

    sudo mkdir -p "$APPLICATION_DEB_DIR"
    (
        echo 'APT::Update::Pre-Invoke {"cd '"$APPLICATION_DEB_DIR"' && wget -qN 'https://zoom.us/client/latest/zoom_amd64.deb' && apt-ftparchive packages . > Packages && apt-ftparchive release . > Release";};' | sudo tee $APPLICATION_APT_CONF
        echo 'deb [trusted=yes lang=none] file:'"$APPLICATION_DEB_DIR"' ./' | sudo tee "$APPLICATION_SOURCE_LIST"
    ) > /dev/null

    package_update
    package_install "$APPLICATION_ID"
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
    sudo rm -rf "$APPLICATION_DEB_DIR"
    sudo rm "$APPLICATION_APT_CONF"
    sudo rm "$APPLICATION_SOURCE_LIST"
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
