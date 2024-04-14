#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Docker [official repository]"
readonly APPLICATION_ID="docker-ce"
readonly APPLICATION_KEYRING=/etc/apt/keyrings/docker.gpg
readonly APPLICATION_SOURCE_LIST=/etc/apt/sources.list.d/docker.list

# Function to get the Ubuntu codename from Linux Mint
function get_ubuntu_codename_from_mint() {
    codename=$(cat /etc/upstream-release/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2)
    echo "$codename"
}

# Function to get the Ubuntu codename from Ubuntu
function get_ubuntu_codename_from_ubuntu() {
    codename=$(lsb_release -sc)
    echo "$codename"
}

# Function to detect the distribution and get the codename
function get_ubuntu_codename() {
    if [ -f /etc/upstream-release/lsb-release ]; then
        # Mint uses /etc/upstream-release/lsb-release
        ubuntu_codename=$(get_ubuntu_codename_from_mint)
    else
        # Ubuntu uses lsb_release -sc
        ubuntu_codename=$(get_ubuntu_codename_from_ubuntu)
    fi

    echo "$ubuntu_codename"
}

function perform_install() {
    # Add Docker's official GPG key:
    package_update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o "$APPLICATION_KEYRING"
    sudo chmod a+r "$APPLICATION_KEYRING"

    # Add the repository to Apt sources:
    echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=$APPLICATION_KEYRING] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$(get_ubuntu_codename)")" stable" \
        | sudo tee "$APPLICATION_SOURCE_LIST" > /dev/null

    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor --yes -o "$APPLICATION_KEYRING"
    sudo sh -c 'echo "deb [arch=amd64 signed-by='$APPLICATION_KEYRING'] http://dl.google.com/linux/chrome/deb/ stable main" > '$APPLICATION_SOURCE_LIST

    package_update
    package_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo -e "${ORANGE}Docker: execute docker without sudo${NC}"
    sudo usermod -aG docker "${USER}"
}

function perform_uninstall() {
    package_uninstall docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo rm "$APPLICATION_SOURCE_LIST"
    sudo rm "$APPLICATION_KEYRING"
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
