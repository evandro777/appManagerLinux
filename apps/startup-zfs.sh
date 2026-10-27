#!/bin/bash

readonly APPLICATION_NAME="Startup > ZFS filesystems"

function perform_install() {
    echo "Startup > Enable > ZFS: this only matters for ZFS filesystems."
    sudo systemctl enable --now zfs-zed.service zfs-share.service zfs-mount.service zfs-volume-wait.service zfs-import-cache.service
}

function perform_uninstall() {
    echo "Startup > Disable > ZFS: this only matters for ZFS filesystems."
    sudo systemctl disable --now zfs-zed.service zfs-share.service zfs-mount.service zfs-volume-wait.service zfs-import-cache.service
}

function perform_check() {
    package_is_installed=0
    if [ -n "$(zpool list -H -o name 2> /dev/null)" ]; then
        package_is_installed=3
    elif systemctl is-enabled --quiet zfs-zed.service; then
        package_is_installed=1
    fi
    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
