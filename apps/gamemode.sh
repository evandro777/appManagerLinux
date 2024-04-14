#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="GameMode: temporary optimisations (+custom optimisations) [distro repository]"
readonly APPLICATION_ID="gamemode"
# Define possible file paths
readonly FILE_PATHS=(
    "/usr/share/gamemode/gamemode.ini"
    "/etc/gamemode.ini"
)
# Find the existing file path
EXISTING_FILE=""
for path in "${FILE_PATHS[@]}"; do
    if [ -f "$path" ]; then
        EXISTING_FILE="$path"
        break
    fi
done

# Define the new parameters to add
NEW_PARAMS=(
    "start=notify-send \"GameMode started\""
    "end=notify-send \"GameMode ended\""
    "start=dconf write /org/cinnamon/muffin/unredirect-fullscreen-windows true"
    "end=dconf write /org/cinnamon/muffin/unredirect-fullscreen-windows false"
)

# Nvidia status for GPUPowerMizerMode: nvidia-settings -q GPUPowerMizerMode
# Nvidia parameters list: nvidia-settings --describe=all
# Check if nvidia-settings command exists
if command -v nvidia-settings &> /dev/null; then
    NEW_PARAMS+=(
        "start=nvidia-settings -a GPUPowerMizerMode=1"
        "end=nvidia-settings -a GPUPowerMizerMode=2"
    )
fi

# Count the number of existing parameters in the file
EXISTING_PARAM_COUNT=0
for param in "${NEW_PARAMS[@]}"; do
    if grep -q "^$param" "$EXISTING_FILE"; then
        ((EXISTING_PARAM_COUNT++))
    fi
done

# If all parameters found
ALL_PARAMS_FOUND=0
if [ "${#NEW_PARAMS[@]}" -eq "$EXISTING_PARAM_COUNT" ]; then
    ALL_PARAMS_FOUND=1
fi

function perform_install() {
    package_install "$APPLICATION_ID"

    echo -e "${RED}To execute a game using gamemode use:${NC}"
    echo "gamemoderun ./game"
    echo -e "${RED}To execute a steam game using gamemode use > edit the Steam launch options:${NC}"
    echo "gamemoderun %command%"
    echo "View more about at: https://github.com/FeralInteractive/gamemode"

    # Exit if no existing file found
    if [ -z "$EXISTING_FILE" ]; then
        echo "No gamemode.ini file found. Exiting script."
        exit 0
    fi

    # If all parameters found, exit the script
    if [ "$ALL_PARAMS_FOUND" -eq 1 ]; then
        echo "All custom parameters optimisations already exist."
        exit 0
    fi

    # Add the new parameters to the file, skipping duplicates
    for param in "${NEW_PARAMS[@]}"; do
        if ! grep -q "^$param" "$EXISTING_FILE"; then
            echo "$param" | sudo tee -a "$EXISTING_FILE" > /dev/null
        fi
    done

    echo -e "${YELLOW}Custom optimisations added to gamemode${NC}"
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
}

function perform_check() {
    package_is_installed=$(package_is_installed "$APPLICATION_ID")

    if [ "$package_is_installed" -eq 1 ]; then
        if [ "$ALL_PARAMS_FOUND" -eq 0 ]; then
            package_is_installed=0
        fi
    fi
    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
