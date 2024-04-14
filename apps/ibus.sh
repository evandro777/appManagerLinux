#!/bin/bash

readonly APPLICATION_NAME="IBus daemon (Keyboard language & Emojis shortcut: CTRL + ;) + enable startup"
readonly APPLICATION_ID="ibus"
readonly APPLICATION_DESKTOP_ENTRY='[Desktop Entry]
Type=Application
Exec=ibus-daemon --daemonize
X-GNOME-Autostart-enabled=true
NoDisplay=false
Hidden=false
Name[en_US]=IBus daemon
Comment[en_US]=IBus input method
X-GNOME-Autostart-Delay=5'

function perform_install() {
    package_install "$APPLICATION_ID"

    echo -e "${YELLOW}Enable startup $APPLICATION_NAME...${NC}"
    echo "${APPLICATION_DESKTOP_ENTRY}" | tee -a "${HOME}/.config/autostart/IBus daemon.desktop" > /dev/null

    echo "IBus daemon > Change keyboard shortcut to: <CTRL + ;>. Avoid conflict with VS Code"
    dconf write /desktop/ibus/panel/emoji/hotkey "['<Control>semicolon']"

    echo "${YELLOW}To use emoji, press ${RED}CTRL + ;${YELLOW}${NC}"
    echo "${YELLOW}After that, to search an emoji, press ${RED}CTRL + SPACE${YELLOW} type something to search, like 'smile'. Select the emoji${NC}"
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
