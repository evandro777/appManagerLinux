#!/bin/bash

readonly APPLICATION_NAME="Mint Cinnamon > Settings > Startup > Bluetooth"

function perform_install() {
    echo -e "${YELLOW}Enable startup $APPLICATION_NAME...${NC}"

    echo "Startup > Enable > Blueberry"
    startup_enable_app "blueberry-tray" 2> /dev/null       # Hide error message > new mint versions doesn't use blueberry anymore
    startup_enable_app "blueberry-obex-agent" 2> /dev/null # Hide error message > new mint versions doesn't use blueberry anymore
    echo "Startup > Enable > Blueman"
    startup_enable_app "blueman"
}

function perform_uninstall() {
    echo -e "${RED}Disable startup $APPLICATION_NAME...${NC}"

    echo "Startup > Disable > Blueberry"
    startup_disable_app "blueberry-tray" 2> /dev/null       # Hide error message > new mint versions doesn't use blueberry anymore
    startup_disable_app "blueberry-obex-agent" 2> /dev/null # Hide error message > new mint versions doesn't use blueberry anymore
    echo "Startup > Disable > Blueman"
    startup_disable_app "blueman"
}

function perform_check() {
    package_is_installed=0
    if [ "$(startup_is_enable_app blueman)" == "true" ]; then
        package_is_installed=1
    fi
    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/mint-cinnamon-helper.sh" # Include file
. "$DIR/../../includes/header_packages.sh"

exit 0
