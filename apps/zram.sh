#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Zram (compressed RAM swap)"
readonly APPLICATION_ID="zram-tools"
readonly CONFIG_FILE="/etc/default/zramswap"

function perform_install() {
    package_install "$APPLICATION_ID" || return 1

    sudo sed -i -E \
        -e 's/^[[:space:]]*ALGO=.*/ALGO=zstd/' \
        -e 's/^[[:space:]]*PERCENT=.*/PERCENT=25/' \
        "$CONFIG_FILE" || return 1

    for setting in "ALGO=zstd" "PERCENT=25"; do
        key="${setting%%=*}"
        if ! grep -qE "^[[:space:]]*${key}=" "$CONFIG_FILE"; then
            printf '%s\n' "$setting" | sudo tee -a "$CONFIG_FILE" > /dev/null || return 1
        fi
    done

    sudo systemctl restart zramswap
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
}

function perform_check() {
    if [ "$(package_is_installed "$APPLICATION_ID")" -eq 1 ] &&
        grep -qx "ALGO=zstd" "$CONFIG_FILE" &&
        grep -qx "PERCENT=25" "$CONFIG_FILE" &&
        swapon --show=NAME --noheadings --raw | grep -Fxq "/dev/zram0"; then
        echo 1
    else
        echo 0
    fi
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
