#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Xpad Linux Kernel Driver [unofficial Git / don't auto update]"
readonly APPLICATION_ID="xpad"
readonly APPLICATION_VERSION="0.4"

function perform_install() {
    echo "Install ${APPLICATION_ID}"
    exit
    echo -e "Driver for the Xbox, Xbox 360, Xbox 360 Wireless, Xbox One Controllers and similars like 8bitdo and others"
    echo -e "More information at: https://github.com/paroj/xpad"
    echo -e "Alternative to use 8bitdo with xinput without installing: https://gist.github.com/ammuench/0dcf14faf4e3b000020992612a2711e2"
    echo -e "To identify plugged usb gamepad and peripherals, execute: lsusb"

    perform_uninstall

    echo -e "Getting updated version"
    sudo git clone --depth=1 https://github.com/paroj/xpad.git "/usr/src/${APPLICATION_ID}-${APPLICATION_VERSION}"

    echo -e "Installing new driver"
    sudo dkms install -m "$APPLICATION_ID" -v "$APPLICATION_VERSION"
}

function perform_uninstall() {
    echo "Uninstall ${APPLICATION_ID}"
    exit
    echo -e "Clearing already installed driver"
    sudo rm -rf "/usr/src/${APPLICATION_ID}-${APPLICATION_VERSION}"

    echo -e "Removing alterady installed driver"
    sudo dkms remove -m "$APPLICATION_ID" -v "$APPLICATION_VERSION"
}

function perform_check() {
    if sudo dkms status "${APPLICATION_ID}/${APPLICATION_VERSION}" | grep -q installed; then
        echo 1 # Package is installed
    else
        echo 0 # Package is not installed
    fi
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
