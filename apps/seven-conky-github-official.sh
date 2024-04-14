#!/bin/bash

readonly APPLICATION_NAME="*Need fix questions* Seven Conky: Conky with clock, disk, network, process, weather, music [official GitHub]"
readonly APPLICATION_LOCATION="${HOME}/.conky/seven-conky/"

function perform_install() {
    installLocation="${APPLICATION_LOCATION}" autoStart="y" \
        bash <(curl -s https://raw.githubusercontent.com/evandro777/seven-conky/main/install.sh)

    sudo apt-get install -y fonts-font-awesome
    sudo chmod +s /usr/sbin/hddtemp
}

function perform_uninstall() {
    rm -rf "${APPLICATION_LOCATION}"
}

function perform_check() {
    if [ -z "$(ls -A "${APPLICATION_LOCATION}" 2> /dev/null)" ]; then
        echo 0 # not installed
    else
        echo 1 # is installed
    fi
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
