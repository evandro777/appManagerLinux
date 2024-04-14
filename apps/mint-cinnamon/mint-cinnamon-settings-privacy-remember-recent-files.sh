#!/bin/bash

readonly APPLICATION_NAME="Mint Cinnamon > Settings > Privacy > Remember recently accessed files"

function perform_install() {
    echo -e "${YELLOW}Enable $APPLICATION_NAME...${NC}"

    gsettings set org.cinnamon.desktop.privacy remember-recent-files true
}

function perform_uninstall() {
    echo -e "${RED}Disable $APPLICATION_NAME...${NC}"

    gsettings set org.cinnamon.desktop.privacy remember-recent-files false
}

function perform_check() {
    package_is_installed=0
    if [ "$(gsettings get org.cinnamon.desktop.privacy remember-recent-files)" == "true" ]; then
        package_is_installed=1
    fi
    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/mint-cinnamon-helper.sh" # Include file
. "$DIR/../../includes/header_packages.sh"

exit 0
