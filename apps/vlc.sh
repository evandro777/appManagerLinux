#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="VLC [distro repository]"
readonly APPLICATION_ID="vlc"

function perform_install() {
    package_install "$APPLICATION_ID" --install-suggests

    if [[ "$*" == *"--set-preferred-app"* ]]; then
        echo "Setting preferred application for $APPLICATION_NAME"
        set_preferred_app "$(get_video_mime_types)" "$APPLICATION_ID"
    fi
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

# Overwrite Help function
overwrite_show_help() {
    local packageName="${1}"
    show_help "$packageName"
    echo "--set-preferred-app => Set as preferred video application"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
