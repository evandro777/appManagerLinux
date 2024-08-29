#!/bin/bash

readonly APPLICATION_NAME="Mint Cinnamon > Settings > Startup > Redshift [Color temperature, Blue Light Filter]"
readonly APPLICATION_ID="redshift-gtk"
readonly APPLICATION_DESKTOP_FILE_NAME="redshift-gtk"
readonly APPLICATION_DESKTOP_FILE_LOCATION="${HOME}/.config/autostart/${APPLICATION_DESKTOP_FILE_NAME}.desktop"
readonly APPLICATION_DESKTOP_ENTRY='[Desktop Entry]
Encoding=UTF-8
Name=Redshift
Comment=Color temperature adjustment tool
Icon=redshift
Exec=redshift-gtk -t 6000:4500
Terminal=false
Type=Application
NoDisplay=false
Hidden=false
StartupNotify=true
X-GNOME-Autostart-Delay=3
X-GNOME-Autostart-enabled=true'

function perform_install() {
    package_install "$APPLICATION_ID"
    if [ -f "$APPLICATION_DESKTOP_FILE_LOCATION" ]; then
        echo "Redshift desktop entry file found. Changing properties for startup"
        startup_set_app_property "${APPLICATION_DESKTOP_FILE_NAME}" "Hidden" false
        startup_set_app_property "${APPLICATION_DESKTOP_FILE_NAME}" "X-GNOME-Autostart-enabled" true
        startup_set_app_property "${APPLICATION_DESKTOP_FILE_NAME}" "Exec" "redshift-gtk -t 6000:4500"
    else
        echo "Redshift desktop entry file not found. Creating with properties for startup"
        echo "${APPLICATION_DESKTOP_ENTRY}" | tee -a "${APPLICATION_DESKTOP_FILE_LOCATION}" > /dev/null
    fi
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
    startup_set_app_property "${APPLICATION_DESKTOP_FILE_NAME}" "X-GNOME-Autostart-enabled" false
    startup_set_app_property "${APPLICATION_DESKTOP_FILE_NAME}" "Exec" "redshift-gtk"
}

function perform_check() {
    package_is_installed=$(package_is_installed "$APPLICATION_ID")
    if [ "$package_is_installed" -eq 1 ] && [ "$(startup_is_enable_app ${APPLICATION_DESKTOP_FILE_NAME})" != "true" ]; then
        package_is_installed=0
    fi
    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/mint-cinnamon-helper.sh" # Include file
. "$DIR/../../includes/header_packages.sh"

exit 0
