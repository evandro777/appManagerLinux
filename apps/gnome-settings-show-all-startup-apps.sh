#!/bin/bash

readonly APPLICATION_NAME="GNOME > Setting > Show all hidden startup applications"

# Define the source and destination directories
readonly AUTOSTART_ROOT_FOLDER="/etc/xdg/autostart"
readonly AUTOSTART_MYUSER_FOLDER="${HOME}/.config/autostart"
# Find .desktop files with NoDisplay=true in the source directory
readonly AUTOSTART_FILES_HIDDEN=$(grep -rl --include="*.desktop" "NoDisplay=true" "${AUTOSTART_ROOT_FOLDER}")

function perform_install() {
    echo -e "${YELLOW}Applying setting > Show all hidden startup applications${NC}"

    # Create the AUTOSTART_MYUSER_FOLDER directory if it doesn't exist
    mkdir -p "${AUTOSTART_MYUSER_FOLDER}"

    # Copy AUTOSTART_FILES_HIDDEN to the AUTOSTART_MYUSER_FOLDER and change NoDisplay to false
    for file in ${AUTOSTART_FILES_HIDDEN}; do
        # Copy the file to the AUTOSTART_MYUSER_FOLDER
        cp "${file}" "${AUTOSTART_MYUSER_FOLDER}/"

        # Change NoDisplay to false in the copied file
        sed -i 's/NoDisplay=true/NoDisplay=false/g' "${AUTOSTART_MYUSER_FOLDER}/$(basename "${file}")"

        # Set permissions for the current user
        chown "$(whoami)" "${AUTOSTART_MYUSER_FOLDER}/$(basename "${file}")"
    done
}

function perform_uninstall() {
    echo -e "${RED}Resetting settings $APPLICATION_NAME...${NC}"

    # Remove .desktop AUTOSTART_FILES_HIDDEN from the destination directory
    for file in ${AUTOSTART_FILES_HIDDEN}; do
        # Check if the .desktop file exists in the AUTOSTART_MYUSER_FOLDER directory
        if [ -f "${AUTOSTART_MYUSER_FOLDER}/$(basename "${file}")" ]; then
            # Remove the .desktop file from the AUTOSTART_MYUSER_FOLDER
            rm "${AUTOSTART_MYUSER_FOLDER}/$(basename "${file}")"
        fi
    done
}

function perform_check() {
    package_is_installed=0

    # Check if .desktop files need to be removed from the destination directory
    files_in_destination=0
    for file in ${AUTOSTART_FILES_HIDDEN}; do
        # Check if the .desktop file exists in the AUTOSTART_MYUSER_FOLDER directory
        if [ -f "${AUTOSTART_MYUSER_FOLDER}/$(basename "${file}")" ]; then
            ((files_in_destination++))
        fi
    done

    # Compare the total number of files found in destination with the total number of .desktop files
    if [ "${files_in_destination}" -eq "$(echo "${AUTOSTART_FILES_HIDDEN}" | wc -w)" ]; then
        package_is_installed=1
    fi
    echo $package_is_installed
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
