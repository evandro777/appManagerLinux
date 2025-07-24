#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Meld (Compare files) [distro repository]"
readonly APPLICATION_ID="meld"

function perform_install() {
    package_install "$APPLICATION_ID"

    dconf write /org/gnome/meld/indent-width 4
    dconf write /org/gnome/meld/insert-spaces-instead-of-tabs true
    dconf write /org/gnome/meld/highlight-current-line true
    dconf write /org/gnome/meld/show-line-numbers true
    dconf write /org/gnome/meld/prefer-dark-theme true
    dconf write /org/gnome/meld/highlight-syntax true
    dconf write /org/gnome/meld/style-scheme "'dracula'"
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
    dconf reset -f /org/gnome/meld/
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
