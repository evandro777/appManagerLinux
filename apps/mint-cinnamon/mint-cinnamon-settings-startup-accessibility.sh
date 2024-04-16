#!/bin/bash

readonly APPLICATION_NAME="Mint Cinnamon > Settings > Startup > Accessibility [Screen reader, screen keyboard, rename folders by language]"

function perform_install() {
    echo "Startup apps > Which applications to start at login"
    echo -e "${YELLOW}http://askubuntu.com/questions/414841/which-applications-to-start-at-login${NC}"

    echo "Startup > Enable > Accessibility > AT SPI D-Bus Bus AT SPI stands for Assistive Technology Service Provider Interface: unwanted until you need the accessibility features"
    startup_enable_app "at-spi-dbus-bus"

    echo "Startup > Enable > Accessibility > Orca Screen Reader"
    startup_enable_app "orca-autostart"

    echo "Startup > Enable > Accessibility > Caribou (on screen keyboard)"
    startup_enable_app "caribou-autostart"

    echo "Startup > Enable > Accessibility > Rename folders based on language"
    startup_enable_app "user-dirs-update-gtk"
}

function perform_uninstall() {
    echo "Startup > Disable > Accessibility > AT SPI D-Bus Bus AT SPI stands for Assistive Technology Service Provider Interface: unwanted until you need the accessibility features"
    startup_disable_app "at-spi-dbus-bus"

    echo "Startup > Disable > Accessibility > Orca Screen Reader"
    startup_disable_app "orca-autostart"

    echo "Startup > Disable > Accessibility > Caribou (on screen keyboard)"
    startup_disable_app "caribou-autostart"

    echo "Startup > Disable > Accessibility > Rename folders based on language"
    startup_disable_app "user-dirs-update-gtk"
}

function perform_check() {
    package_is_installed=0
    if [ "$(startup_is_enable_app at-spi-dbus-bus)" == "true" ]; then
        package_is_installed=1
    fi
    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/mint-cinnamon-helper.sh" # Include file
. "$DIR/../../includes/header_packages.sh"

exit 0
