#!/bin/bash

#FOLLOW SYMLINK / USE SCRIPT DIRECTORY
#MAY CAUSE PROBLEM WHEN EXECUTING FROM OTHER DIRECTORIES. BETTER BE THE LAST ONE TO EXECUTE
cd "$(dirname "$(realpath "$0")")" || exit

# Font colors & style > If using with color, it MUST be putted AFTER the color

readonly BOLD=$(tput bold)       # Sets text to bold
readonly BLINK=$(tput blink)     # Makes text blink
readonly UNDER=$(tput smul)      # Underlines text
readonly NORMAL=$(tput sgr0)     # Turn off all attributes
readonly DIM=$(tput dim)         # Sets text to dim (less bright) mode
readonly REVERSE=$(tput rev)     # Reverses background and color
readonly INVISIBLE=$(tput invis) # Hides text
readonly ITALIC=$(tput sitm)     # Sets text to italic mode
readonly NO_ITALIC=$(tput ritm)  # Disables italic mode

# Reset
readonly RESET=$(tput reset) # Reset all
readonly NC='\033[0m'        # No Color / Reset all

# Regular Colors
readonly BLACK="\033[0;30m"  # Black
readonly RED="\033[0;31m"    # Red
readonly GREEN="\033[0;32m"  # Green
readonly YELLOW="\033[0;33m" # Yellow
readonly BLUE="\033[0;34m"   # Blue
readonly PURPLE="\033[0;35m" # Purple
readonly CYAN="\033[0;36m"   # Cyan
readonly WHITE="\033[0;37m"  # White

# Background
readonly BG_BLACK="\033[40m"  # Black
readonly BG_RED="\033[41m"    # Red
readonly BG_GREEN="\033[42m"  # Green
readonly BG_YELLOW="\033[43m" # Yellow
readonly BG_BLUE="\033[44m"   # Blue
readonly BG_PURPLE="\033[45m" # Purple
readonly BG_CYAN="\033[46m"   # Cyan
readonly BG_WHITE="\033[47m"  # White

# High Intensity
readonly I_BLACK="\033[0;90m"  # Black
readonly I_RED="\033[0;91m"    # Red
readonly I_GREEN="\033[0;92m"  # Green
readonly I_YELLOW="\033[0;93m" # Yellow
readonly I_BLUE="\033[0;94m"   # Blue
readonly I_PURPLE="\033[0;95m" # Purple
readonly I_CYAN="\033[0;96m"   # Cyan
readonly I_WHITE="\033[0;97m"  # White

# High Intensity backgrounds
readonly BGI_BLACK="\033[0;100m"  # Black
readonly BGI_RED="\033[0;101m"    # Red
readonly BGI_GREEN="\033[0;102m"  # Green
readonly BGI_YELLOW="\033[0;103m" # Yellow
readonly BGI_BLUE="\033[0;104m"   # Blue
readonly BGI_PURPLE="\033[10;95m" # Purple
readonly BGI_CYAN="\033[0;106m"   # Cyan
readonly BGI_WHITE="\033[0;107m"  # White

#Insert or update settings. Alternative to crudini, which insert spaces between equal, example: " = "
#Example: set_property "${HOME}/.config/autostart/mintwelcome.desktop" "X-GNOME-Autostart-enabled" false
#Result: X-GNOME-Autostart-enabled=false
#$1: file
#$2: property
#$3: value
function set_property() {
    local file_location="${1}"
    local property="${2}"
    local value="${property}=${3}"

    if ! grep -q "${property}" "${file_location}"; then
        # Check if the file can be edited directly or needs sudo
        if [ -w "${file_location}" ]; then
            # Insert without sudo
            echo "${value}" >> "${file_location}"
        else
            # Insert with sudo
            echo "${value}" | sudo tee -a "${file_location}" > /dev/null
        fi
    else
        # Update with or without sudo depending on the permission
        if [ -w "${file_location}" ]; then
            # Update without sudo
            sed -i s/"${property}".*$/"${value}"/ "${file_location}"
        else
            # Update with sudo
            sudo sed -i s/"${property}".*$/"${value}"/ "${file_location}"
        fi
    fi
}

#Remove settings
#Example: remove_property "${HOME}/.config/autostart/mintwelcome.desktop" "X-GNOME-Autostart-enabled"
#Result: Remove line which contains X-GNOME-Autostart-enabled=
#$1: file
#$2: property
function remove_property() {
    local file_location="${1}"
    local property="${2}="

    if grep -q "${property}" "${file_location}"; then
        # Check if the file can be edited directly or needs sudo
        if [ -w "${file_location}" ]; then
            # Remove without sudo
            sed -i "/^${property}/d" "${file_location}"
        else
            # Remove with sudo
            sudo sed -i "/^${property}/d" "${file_location}"
        fi
    fi
}

#Ps.: Force remove white spaces " = ", happens when creating a new file, when editing a file that already doesn't have, it isn't needed
#Force remove white spaces " = " between key and value
#Example: trim_properties "${HOME}/.config/autostart/mintwelcome.desktop"
#$1: file
function trim_properties() {
    local file_location="${1}"

    sed -i -r "s/(\S*)\s*=\s*(.*)/\1=\2/g" "${file_location}"
}

function command_dependency() {
    local command_name="${1}"
    command -v "$command_name" > /dev/null 2>&1 || {
        echo -e "${RED}$command_name${NC} is required but it's not installed! Aborting." >&2
        exit 1
    }
}

# Check if a single package is installed
function package_is_installed() {
    local package_name=$1

    if dpkg -l | awk '$1=="ii" {print $2}' | sed 's/:.*//' | grep -qx "${package_name}"; then
        echo 1 # Package is installed
    else
        echo 0 # Package is not installed
    fi
}

# Check if multiple packages is installed
function packages_is_installed() {
    local search_string=$1

    # Remove "*" character if present in the search string
    search_string=${search_string//\*/}

    # Search for packages matching the search string
    search_results=$(apt search "$search_string" | grep -v "^i")

    # Check if there are any packages available for installation
    if [ -z "$search_results" ]; then
        echo 1 # Package is installed
    else
        echo 0 # Package is not installed
    fi
}

# Function to update cache
function package_update() {
    echo "Update apt cache"
    # Run apt-get update and redirect output to a variable
    output=$(sudo apt-get -y -q update 2>&1)

    # Check the return code of the previous command
    if [ $? -ne 0 ]; then
        # Display the output only if an error occurred
        echo "$output"
    fi
}

# Function to install packages
function package_install() {
    # Evaluate the arguments as a list of separate arguments.
    # Example package_install "zsh zsh-autosuggestions", will be: sudo apt-get install -y -q "zsh" "zsh-autosuggestions"
    eval "sudo apt-get install -y -q $*"
}

# Function to uninstall packages
function package_uninstall() {
    # Evaluate the arguments as a list of separate arguments
    eval "sudo apt-get purge -y -q $*"
    sudo apt-get autoremove -y -q
}

# Function to check if a flatpak is installed
function flatpak_is_installed() {
    local flatpak_name=$1

    if flatpak list | grep -q "$flatpak_name"; then
        echo 1 # Flatpak is installed
    else
        echo 0 # Flatpak is not installed
    fi
}

# Function to install flatpak
function flatpak_install() {
    # Evaluate the arguments as a list of separate arguments
    eval "flatpak install --noninteractive -y $*"
}

# Function to uninstall packages
function flatpak_uninstall() {
    # Evaluate the arguments as a list of separate arguments
    eval "flatpak uninstall -y --noninteractive --delete-data $*"
}

#Return a list of video mime types
#Example: get_video_mime_types
function get_video_mime_types() {
    grep < /usr/share/applications/defaults.list "video/\|x-content/video-" | sed 's/=.*$//g'
}

#Set preferred apps
#Example:
#	videoMimeTypes=$(cat /usr/share/applications/defaults.list | grep "video/\|x-content/video-" | sed 's/=.*celluloid_player.*$//g')
#	SetPreferredVideoApp $video_mime_types smplayer
#$1: array of mime_types
#$2: app name
#$3: file location
function set_preferred_app() {
    local mime_types="${1}"
    local app_name="${2}"
    local file_location="${HOME}/.config/mimeapps.list" # Ubuntu >= 16.04
    #local fileLocation=$([ "${3}" ] && echo "${3}" || echo ${HOME}/.config/mimeapps.list)

    for mimeType in "${mime_types[@]}"; do
        crudini --set "${file_location}" "Default Applications" "$mimeType" "${app_name}".desktop
        crudini --set "${file_location}" "Added Associations" "$mimeType" "${app_name}".desktop
    done

    #Force remove white spaces " = ", happens when creating a new file, when editing a file that already doesn't have, it isn't needed
    trim_properties "${file_location}"
}

# Function to check if a process is running
function is_process_running() {
    local process_name=$1

    if pgrep "$process_name" > /dev/null; then
        return 0 #Process is running
        echo 1
    else
        return 1 #Process not running
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

    new_custom_id=$(get_new_keybinding_id)
    if [ -z "$(keybinding_exists "$keybinding")" ]; then
        # Check if custom-list is empty
        if [ -z "$(dconf read /org/cinnamon/desktop/keybindings/custom-list)" ]; then
            # dconf write /org/cinnamon/desktop/keybindings/custom-list "['_dummy_']"
            set_list="['$new_custom_id']"
        else
            set_list=$(dconf read /org/cinnamon/desktop/keybindings/custom-list | sed -r "s/\[/['${new_custom_id}', /g")
        fi

        dconf write /org/cinnamon/desktop/keybindings/custom-list "${set_list}"
        dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/"${new_custom_id}"/name "'$name'"
        dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/"${new_custom_id}"/command "'$command'"
        dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/"${new_custom_id}"/binding '['"$keybinding"']'
    else
        echo -e "Shortcut has already been using"
    fi
}

# Function to update the file and perform the replacement
update_json_prop_file() {
    # $1: The jq command to update the file
    # $2: The path to the settings file
    jq "$1" "$2" > temp.json && mv temp.json "$2"
}
