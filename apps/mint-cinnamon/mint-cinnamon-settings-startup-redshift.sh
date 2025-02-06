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
Exec=sh -c "killall redshift; sleep 5; redshift-gtk -t 6000:4500"
Terminal=false
Type=Application
NoDisplay=false
Hidden=false
StartupNotify=true
X-GNOME-Autostart-Delay=3
X-GNOME-Autostart-enabled=true'
readonly APPLICATION_CONFIG_FILE_LOCATION="$HOME/.config/redshift.conf"
readonly APPLICATION_CONFIG_FILE_CONTENTS='[redshift]
dawn-time=05:00-05:30
dusk-time=19:00-21:00

; When time-based adjustment (dawn and dusk time) is specified, no location provider is needed and it will therefore not be initialized and used
location-provider=manual
[manual]
lat=40.6893129
lon=-74.0445531'

function perform_install() {
    echo "Redshift is not working anymore without extra configurations: https://www.linuxmint.com/rel_wilma.php"
    echo "To work properly we have to manually set the location or set dawn and dusk time"
    echo "To make it easier, a default config is created at: $APPLICATION_CONFIG_FILE_LOCATION"
    echo "It's is set time-base adjustment (dawn start at 05 and dusk start at 19). To change, edit the .conf file"
    echo "To use and get location: go to http://maps.google.com/ search your location > right mouse click > click on the first item which is coordinates and will be copied to clipboard"
    echo "At the .conf file, change 'lat' with the first party of copied coordinates, and 'lon' with the last part"
    echo "Comment dawn-time and dusk-time to use location"

    # Check if the configuration file exists
    if [ ! -f "$APPLICATION_CONFIG_FILE_LOCATION" ]; then
        echo "$APPLICATION_CONFIG_FILE_CONTENTS" > "$APPLICATION_CONFIG_FILE_LOCATION"
    fi

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
    rm "$APPLICATION_CONFIG_FILE_LOCATION"
}

function perform_check() {
    package_is_installed=$(package_is_installed "$APPLICATION_ID")

    if [ "$package_is_installed" -eq 1 ]; then
        if [ "$(startup_is_enable_app ${APPLICATION_DESKTOP_FILE_NAME})" != "true" ] || [ ! -f "$APPLICATION_CONFIG_FILE_LOCATION" ]; then
            package_is_installed=0
        fi
    fi
    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/mint-cinnamon-helper.sh" # Include file
. "$DIR/../../includes/header_packages.sh"

exit 0
