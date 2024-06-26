#!/bin/bash

#Get startup app property
#$1: property
#$2: filename
function startup_get_app_property() {
    local filename="${1}"
    local property="${2}"
    local desktop_filename="${HOME}/.config/autostart/${filename}.desktop"

    if [ ! -f "$desktop_filename" ]; then # If home autostart is not found, tries global "/etc"
        desktop_filename="/etc/xdg/autostart/${filename}.desktop"
    fi

    if [ ! -f "$desktop_filename" ]; then # If none is found, exits function
        return
    fi

    if command -v crudini &> /dev/null; then
        crudini --get "${desktop_filename}" "Desktop Entry" "${property}"
    else
        grep -oP "(?<=^${property}=).*" "${desktop_filename}"
    fi
}

#Change startup apps settings
#$1: property (search)
#$2: value
#$3: file location
#Example:
#startup_set_app_property "X-GNOME-Autostart-enabled" false "${HOME}/.config/autostart/${1}.desktop"
function startup_set_app_property() {
    local filename="${1}"
    local property="${2}"
    local value="${3}"

    #Using crudini to set values, would insert spaces between " = ", which doesn't have in ".desktop" files
    #crudini --set "${filename}" "Desktop Entry" "${property}" "${value}"
    set_property "${HOME}/.config/autostart/${filename}.desktop" "${property}" "${value}"
}

#Enable autostart
#$3: filename
function startup_enable_app() {
    local filename="${1}"
    rm "${HOME}/.config/autostart/${filename}.desktop" # Remove the user, doesn't need to set "X-GNOME-Autostart-enabled true", because the default is already enabled
    # cp "/etc/xdg/autostart/${filename}.desktop" "${HOME}/.config/autostart/"
    # startup_set_app_property "${filename}" "X-GNOME-Autostart-enabled" true
}

#Disable autostart
#$3: filename
function startup_disable_app() {
    local filename="${1}"
    cp "/etc/xdg/autostart/${filename}.desktop" "${HOME}/.config/autostart/"
    startup_set_app_property "${filename}" "X-GNOME-Autostart-enabled" false
}

#Is autostart enabled
#$1: filename
function startup_is_enable_app() {
    local filename="${1}"
    local property="X-GNOME-Autostart-enabled"
    local desktop_filename_user="${HOME}/.config/autostart/${filename}.desktop"
    local desktop_filename_global="/etc/xdg/autostart/${filename}.desktop"

    if [ -f "$desktop_filename_user" ]; then # If home autostart is found > check property
        if command -v crudini &> /dev/null; then
            crudini --get "${desktop_filename_user}" "Desktop Entry" "${property}"
        else
            grep -oP "(?<=^${property}=).*" "${desktop_filename_user}"
        fi
    elif [ -f "${desktop_filename_global}" ]; then # If global desktop file is found > it is already an autostart app
        echo "true"
    fi
}
