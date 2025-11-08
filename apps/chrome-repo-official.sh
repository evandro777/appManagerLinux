#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Chrome [official repository]"
#stable: google-chrome-stable, beta: google-chrome-beta, unstable: google-chrome-unstable
readonly APPLICATION_ID="google-chrome-stable"
readonly APPLICATION_KEYRING=/etc/apt/keyrings/chrome.gpg
readonly APPLICATION_SOURCE_LIST=/etc/apt/sources.list.d/google.list
readonly APPLICATION_SYSTEM_DESKTOP_FILE="/usr/share/applications/google-chrome.desktop"
readonly APPLICATION_USER_DESKTOP_FILE="$HOME/.local/share/applications/google-chrome.desktop"

function perform_install() {
    wget -q -O - "https://dl.google.com/linux/linux_signing_key.pub" | sudo gpg --dearmor --yes -o "$APPLICATION_KEYRING"
    sudo sh -c 'echo "deb [arch=amd64 signed-by='$APPLICATION_KEYRING'] http://dl.google.com/linux/chrome/deb/ stable main" > '$APPLICATION_SOURCE_LIST
    package_update
    package_install "$APPLICATION_ID"
    enableHardwareAcceleration
    echo -e "Chrome > After install > Removing duplicate source entry"
    sudo rm /etc/apt/sources.list.d/google-chrome.list &> /dev/null
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
    sudo rm "$APPLICATION_SOURCE_LIST"
    sudo rm "$APPLICATION_KEYRING"
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

function enableHardwareAcceleration() {
    # Check if the system desktop file exists
    if [[ ! -f "$APPLICATION_SYSTEM_DESKTOP_FILE" ]]; then
        echo "Error: Chrome .desktop file not found at $APPLICATION_SYSTEM_DESKTOP_FILE"
        return 1
    fi

    # Ensure user applications directory exists
    mkdir -p "$(dirname "$APPLICATION_USER_DESKTOP_FILE")"
    cp "$APPLICATION_SYSTEM_DESKTOP_FILE" "$APPLICATION_USER_DESKTOP_FILE"

    # Define Chrome flags to be added
    CHROME_FLAGS="--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder"

    # Update Exec lines to include the desired flags
    # Handles multiple Exec entries (for stable, incognito, etc.)
    sed -i -E "s|^(Exec=.*google-chrome-stable)|\1 $CHROME_FLAGS|" "$APPLICATION_USER_DESKTOP_FILE"

    echo "Install an extension 'enhanced-h264ify', to disable specific codecs (like av1, vp8, vp8, etc):"
    echo "https://chromewebstore.google.com/detail/enhanced-h264ify/omkfmpieigblcllmkgbflkikinpkodlk"

    echo "Check more information about chrome and hardware acceleration at:"
    echo "https://wiki.archlinux.org/title/Chromium#Hardware_video_acceleration"

    echo "Codecs for Intel GPU: https://en.wikipedia.org/wiki/Intel_Quick_Sync_Video#Hardware_decoding_and_encoding)"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
