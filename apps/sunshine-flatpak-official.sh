#!/bin/bash

readonly APPLICATION_NAME="Sunshine GameStream (server for Moonlight) [official Flatpak]"
readonly APPLICATION_ID="dev.lizardbyte.app.Sunshine"
readonly APPLICATION_CONFIG_DIR="$HOME/.var/app/$APPLICATION_ID/config/sunshine"
readonly SUNSHINE_APPS_FILE="$APPLICATION_CONFIG_DIR/apps.json"
readonly SUNSHINE_JSON_CONFIG=$(
    cat << EOF
{
    "env": {
        "PATH": "\$(PATH):\$(HOME)\/.local\/bin"
    },
    "apps": [
        {
            "name": "Desktop",
            "image-path": "desktop.png"
        },
        {
            "name": "Steam Big Picture",
            "cmd": "flatpak-spawn --host steam -gamepadui",
            "image-path": "steam.png"
        }
    ]
}
EOF
)

function perform_install() {
    flatpak_install "$APPLICATION_ID"

    echo "Executing extra steps, according to: https://flathub.org/apps/dev.lizardbyte.app.Sunshine"
    flatpak run --command=additional-install.sh "$APPLICATION_ID"

    echo "Applying config to avoid micro stuttering and screen tearing on host using flatpak"
    flatpak override --user --socket=session-bus "$APPLICATION_ID"

    create_update_app_steam

    if command -v ufw &> /dev/null; then
        echo "UFW firewall detected. Creating exception rules"
        sudo ufw allow 47984/tcp comment 'Sunshine: All'
        sudo ufw allow 47989/tcp comment 'Sunshine: All'
        sudo ufw allow 47990/tcp comment 'Sunshine: All'
        sudo ufw allow 48010/tcp comment 'Sunshine: All'
        sudo ufw allow 47998:48000/udp comment 'Sunshine: All'
        echo "Showing UFW created rules"
        sudo ufw status | grep "Sunshine: All"
    fi

    echo -e "${RED}First login${NC} access https://localhost:47990/"
    echo -e "${RED}user:${NC} sunshine"
    echo -e "${RED}password:${NC} sunshine"

    echo -e "${RED}To add steam as an application, use this as command:${NC} flatpak-spawn --host /usr/games/steam -gamepadui"

}

function perform_uninstall() {
    flatpak_uninstall "$APPLICATION_ID"

    if command -v ufw &> /dev/null; then
        echo "UFW firewall detected. Removing exception rules"
        sudo ufw status numbered | grep "Sunshine: All" | awk -F'[][]' '{print $2}' | sort -nr | while read -r rule; do
            yes | sudo ufw delete "$rule"
        done
    fi
}

function perform_check() {
    flatpak_is_installed "$APPLICATION_ID"
}

function create_update_app_steam() {
    echo "Creating/update Steam App entry"

    mkdir -p "$APPLICATION_CONFIG_DIR"

    # if file doesn't exist
    if [ ! -f "$SUNSHINE_APPS_FILE" ]; then
        echo "$SUNSHINE_JSON_CONFIG" > "$SUNSHINE_APPS_FILE"
    else
        jq --indent 4 --argjson new_config "$SUNSHINE_JSON_CONFIG" '. * $new_config' "$SUNSHINE_APPS_FILE" > tmp_config.json && mv tmp_config.json "$SUNSHINE_APPS_FILE"
    fi
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
