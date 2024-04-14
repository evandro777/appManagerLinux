#!/bin/bash

readonly IS_APT_PACKAGE=1

if [[ $DESKTOP_SESSION == "cinnamon" ]]; then
    readonly APPLICATION_NAME="Dropbox (with Nemo integration) [distro repository]"
    readonly APPLICATION_ID="nemo-dropbox"
else
    readonly APPLICATION_NAME="Dropbox [distro repository]"
    readonly APPLICATION_ID="dropbox"
fi

function perform_install() {
    package_install $APPLICATION_ID
    if [[ $DESKTOP_SESSION == "cinnamon" ]]; then
        echo "Add shortcut (bookmarks) to nemo"
        file="${HOME}/.config/gtk-3.0/bookmarks"
        line="file://${HOME}/Dropbox Dropbox"
        # Check if file already exists in file
        if ! grep -qFx "$line" "$file"; then
            printf "$line\n" >> "$file"
        fi
    fi
}

function perform_uninstall() {
    readonly APPLICATION_ID="nemo-dropbox dropbox"
    package_uninstall "$APPLICATION_ID"
}

function perform_check() {
    package_is_installed $APPLICATION_ID
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
