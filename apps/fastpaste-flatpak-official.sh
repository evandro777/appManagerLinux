#!/bin/bash

readonly APPLICATION_NAME="FastPaste (clipboard history) [official Flatpak]"
readonly APPLICATION_ID="io.github.evandro777.FastPaste"
readonly REMOTE_NAME="fastpaste"
readonly REMOTE_URL="https://evandro777.github.io/FastPaste/fastpaste.flatpakrepo"

function perform_install() {
    flatpak remote-add --system --if-not-exists "$REMOTE_NAME" "$REMOTE_URL"
    flatpak_install --system "$REMOTE_NAME" "$APPLICATION_ID"
}

function perform_uninstall() {
    flatpak_uninstall --system "$APPLICATION_ID"
}

function perform_check() {
    if flatpak info --system "$APPLICATION_ID" &>/dev/null; then
        echo 1
    else
        echo 0
    fi
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
