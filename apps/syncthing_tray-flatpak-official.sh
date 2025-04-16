#!/bin/bash

readonly APPLICATION_NAME="Syncthing Tray [official Flatpak]"
readonly APPLICATION_ID="io.github.martchus.syncthingtray"
readonly APPLICATION_DESKTOP_FILE_NAME="syncthing-tray"
readonly APPLICATION_DESKTOP_FILE_LOCATION="${HOME}/.config/autostart/${APPLICATION_DESKTOP_FILE_NAME}.desktop"
readonly APPLICATION_DESKTOP_ENTRY='[Desktop Entry]
Encoding=UTF-8
Name=Syncthing Tray
Comment=Tray application for Syncthing
Icon=syncthing
Exec=/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=syncthingtray '$APPLICATION_ID'
Terminal=false
Type=Application
NoDisplay=false
Hidden=false
StartupNotify=true
X-GNOME-Autostart-Delay=3
X-GNOME-Autostart-enabled=true'

function perform_install() {
    flatpak_install "$APPLICATION_ID"
    flatpak override --user --socket=session-bus "$APPLICATION_ID"

    if [ -f "$APPLICATION_DESKTOP_FILE_LOCATION" ]; then
        echo "Syncthing Tray desktop entry file found. Changing properties for startup"
        startup_set_app_property "${APPLICATION_DESKTOP_FILE_NAME}" "Hidden" false
        startup_set_app_property "${APPLICATION_DESKTOP_FILE_NAME}" "X-GNOME-Autostart-enabled" true
        startup_set_app_property "${APPLICATION_DESKTOP_FILE_NAME}" "Exec" "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=syncthingtray $APPLICATION_ID"
    else
        echo "Syncthing Tray desktop entry file not found. Creating with properties for startup"
        echo "${APPLICATION_DESKTOP_ENTRY}" | tee -a "${APPLICATION_DESKTOP_FILE_LOCATION}" > /dev/null
    fi
}

function perform_uninstall() {
    flatpak_uninstall "$APPLICATION_ID"
    rm "$APPLICATION_DESKTOP_FILE_LOCATION"
}

function perform_check() {
    flatpak_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
