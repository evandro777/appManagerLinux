#!/bin/bash

readonly APPLICATION_NAME="Mint Cinnamon > Settings > Startup > Redshift [Color temperature, Blue Light Filter]"
readonly APPLICATION_DESKTOP_FILE_NAME="redshift-gtk"
readonly APPLICATION_DESKTOP_FILE_LOCATION="${HOME}/.config/autostart/${APPLICATION_DESKTOP_FILE_NAME}.desktop"
readonly APPLICATION_DESKTOP_ENTRY='[Desktop Entry]
Type=Application
Exec=ibus-daemon --daemonize
X-GNOME-Autostart-enabled=true
NoDisplay=false
Hidden=false
Name[en_US]=IBus daemon
Comment[en_US]=IBus input method
X-GNOME-Autostart-Delay=5'

function perform_install() {
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
    startup_set_app_property "${APPLICATION_DESKTOP_FILE_NAME}" "X-GNOME-Autostart-enabled" false
    startup_set_app_property "${APPLICATION_DESKTOP_FILE_NAME}" "Exec" "redshift-gtk"
}

function perform_check() {
    package_is_installed=0
    if [ "$(startup_is_enable_app ${APPLICATION_DESKTOP_FILE_NAME})" == "true" ]; then
        package_is_installed=1
    fi
    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/mint-cinnamon-helper.sh" # Include file
. "$DIR/../../includes/header_packages.sh"

exit 0
