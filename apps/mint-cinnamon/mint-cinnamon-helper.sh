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

# Get Last Id From Keybinding
function get_keybinding_last_id() {
    local list_id=$(dconf read /org/cinnamon/desktop/keybindings/custom-list)
    if [ "$list_id" == "" ]; then
        list_id="[]"
    fi

    # Need to get first and last sequence, because sometimes the bigger id is the first one, sometimes is the last one
    # Get first sequence
    first_id=${list_id:2:10}                            # Get 10 first chars (except first 2)
    first_id=$(echo "${first_id}" | sed 's/[^0-9]*//g') # Remove all except numbers

    # Get last sequence
    last_id=${list_id::-2}                            # Remove 2 last chars
    last_id=${list_id: -7}                            # Get 7 last chars
    last_id=$(echo "${last_id}" | sed 's/[^0-9]*//g') # Remove all except numbers

    if ((first_id >= last_id)); then
        id=$first_id
    else
        id=$last_id
    fi

    if [ "$id" == "" ]; then
        id="-1" # Force -1 (doesn't exist the id). So the next id will be 0
    fi
    echo "$id"
}

# Return string if keybinding is found
#$1: keybinding (example: <Super>Print)
function keybinding_exists() {
    local key_binding="$1"
    local return=$(dconf dump /org/cinnamon/desktop/keybindings/ | grep "${key_binding}")
    echo "$return"
}

# Return a new id to use with custom keybinding
function get_new_keybinding_id() {
    last_id=$(get_keybinding_last_id)
    new_id=$(($last_id + 1))
    new_custom_id="custom${new_id}"
    echo "$new_custom_id"
}

# Set new custom keybinding
# Example: set_new_keybinding "Teste" "flameshot gui" "'<Super>A'"
# Warning: the third parameter must use "'"
function set_new_keybinding() {
    local name="${1}"
    local command="${2}"
    local keybinding="${3}"

    # Check if custom-list is empty > create a dummy one
    if [ -z "$(dconf read /org/cinnamon/desktop/keybindings/custom-list)" ]; then
        dconf write /org/cinnamon/desktop/keybindings/custom-list "['_dummy_']"
    fi

    new_custom_id=$(get_new_keybinding_id)
    if [ -z "$(keybinding_exists "$keybinding")" ]; then
        set_list=$(dconf read /org/cinnamon/desktop/keybindings/custom-list | sed -r "s/\[/['${new_custom_id}', /g")
        dconf write /org/cinnamon/desktop/keybindings/custom-list "${set_list}"
        dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/"${new_custom_id}"/name "'$name'"
        dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/"${new_custom_id}"/command "'$command'"
        dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/"${new_custom_id}"/binding '['"$keybinding"']'
    else
        echo -e "Shortcut has already been using"
    fi
}
