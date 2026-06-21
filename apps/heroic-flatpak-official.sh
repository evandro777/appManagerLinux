#!/bin/bash

readonly APPLICATION_NAME="Heroic + gamescope + MangoHud [official Flatpak]"
readonly APPLICATION_ID="com.heroicgameslauncher.hgl"
readonly APPLICATION_CONFIG_DIR="$HOME/.var/app/$APPLICATION_ID/config/heroic"
readonly HEROIC_CONFIG_FILE="$APPLICATION_CONFIG_DIR/config.json"
readonly GAMESCOPE_ID="org.freedesktop.Platform.VulkanLayer.gamescope//25.08"
readonly MANGOHUD_ID="org.freedesktop.Platform.VulkanLayer.MangoHud//25.08"
readonly HEROIC_JSON_CONFIG=$(
    cat << EOF
{
    "defaultSettings": {
        "analyticsOptIn": true,
        "libraryTopSection": "recently_played_installed",
        "showFps": true,
        "downloadProtonToSteam": true,
        "useSteamRuntime": true,
        "disableController": true,
        "framelessWindow": true
    }
}
EOF
)

function perform_install() {
    flatpak_install "$APPLICATION_ID"
    flatpak_install "$GAMESCOPE_ID"
    flatpak_install "$MANGOHUD_ID"
    apply_settings

}

function perform_uninstall() {
    flatpak_uninstall "$APPLICATION_ID"
    flatpak_uninstall "$GAMESCOPE_ID"
    flatpak_uninstall "$MANGOHUD_ID"
}

function perform_check() {
    heroic_is_installed=$(flatpak_is_installed "$APPLICATION_ID")
    gamescope_is_installed=$(flatpak_is_installed "$GAMESCOPE_ID")
    mangohud_is_installed=$(flatpak_is_installed "$MANGOHUD_ID")
    [[ "$heroic_is_installed" == "0" || "$gamescope_is_installed" == "0" || "$mangohud_is_installed" == "0" ]] && echo "0"
    echo "1"
}

function apply_settings() {
    echo "Applying settings"
    echo "${RED}Disabling navigation using controller > Bugged, when playing a game, it is also navigating and changing settings${NC}"

    mkdir -p "$APPLICATION_CONFIG_DIR"

    # if file doesn't exist
    if [ ! -f "$HEROIC_CONFIG_FILE" ]; then
        echo "$HEROIC_JSON_CONFIG" > "$HEROIC_CONFIG_FILE"
    else
        jq --indent 4 --argjson new_config "$HEROIC_JSON_CONFIG" '. * $new_config' "$HEROIC_CONFIG_FILE" > tmp_config.json && mv tmp_config.json "$HEROIC_CONFIG_FILE"
    fi
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
