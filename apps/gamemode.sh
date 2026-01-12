#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="GameMode + distro game optimizations [distro repository]"
readonly APPLICATION_ID="gamemode"
readonly APPLICATION_INI="$HOME/.config/gamemode.ini"
readonly APPLICATION_CONFIG_PATH="$HOME/.config/gamemode"
readonly GAMEMODE_SERVICE_OVERRIDE_FILE="$HOME/.config/systemd/user/gamemoded.service.d/override.conf"
readonly GAMEMODE_SERVICE_OVERRIDE_CONTENT=$(
    cat << 'EOF'
[Service]
LimitRTPRIO=50
LimitNICE=-10
LimitMEMLOCK=unlimited
NoNewPrivileges=false
EOF
)
readonly GAMEMODE_SUDOERS_FILE="/etc/sudoers.d/gamemode"
readonly GAMEMODE_SUDOERS_CONTENT=$(
    cat << EOF
# sudoers for GameMode tuning (generated)
# Allowed without password only for the specific commands required by gamemode.sh
$USER ALL=(root) NOPASSWD: \\
    /usr/bin/cpupower idle-set --disable-by-latency *, \\
    /usr/bin/cpupower idle-set --enable-all, \\
    /usr/bin/powerprofilesctl set performance, \\
    /usr/bin/powerprofilesctl set balanced, \\
    /usr/sbin/rfkill block bluetooth, \\
    /usr/sbin/rfkill unblock bluetooth, \\
    /usr/bin/systemctl stop bluetooth.service, \\
    /usr/bin/systemctl start bluetooth.service, \\
    /usr/bin/tee /sys/module/usbcore/parameters/autosuspend
EOF
)
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
    "start=~/.config/gamemode/gamemode_hook.sh start > ~/.config/gamemode/debug.log"
    "end=~/.config/gamemode/gamemode_hook.sh end >> ~/.config/gamemode/debug.log"
)

# Function to check if all parameters exist in the file
function check_params_exist() {
    local EXISTING_PARAM_COUNT=0

    # Check if the destination file already exists
    if [ ! -e "$APPLICATION_INI" ]; then
        echo 0
        return
    fi

    # Count the number of parameters found in the file
    for param in "${NEW_PARAMS[@]}"; do
        if grep -q "^$param" "$APPLICATION_INI"; then
            ((EXISTING_PARAM_COUNT++))
        fi
    done

    # Return 1 if all parameters were found, 0 otherwise
    if [ "${#NEW_PARAMS[@]}" -eq "$EXISTING_PARAM_COUNT" ]; then
        echo 1
    else
        echo 0
    fi
}

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

    # Check if the destination file already exists
    if [ ! -e "$APPLICATION_INI" ]; then
        # Create user application ini from default
        cp "$EXISTING_FILE" "$APPLICATION_INI"
    fi

    echo "Copying gamemode_hook.sh: ${APPLICATION_CONFIG_PATH}/gamemode_hook.sh"
    mkdir -p "${APPLICATION_CONFIG_PATH}"
    cp "gamemode_hook.sh" "${APPLICATION_CONFIG_PATH}/gamemode_hook.sh"

    echo "Creating sudoers: $GAMEMODE_SUDOERS_FILE"
    sudo bash -c "echo '$GAMEMODE_SUDOERS_CONTENT' > '$GAMEMODE_SUDOERS_FILE'"

    # If all parameters found, exit the script
    if [ "$(check_params_exist)" = 1 ]; then
        echo "All custom parameter optimizations already exist."
    else
        # Add the new parameters to the file, skipping duplicates
        for param in "${NEW_PARAMS[@]}"; do
            if ! grep -q "^$param" "$APPLICATION_INI"; then
                echo "$param" | sudo tee -a "$APPLICATION_INI" > /dev/null
            fi
        done
    fi

    crudini --set "$APPLICATION_INI" "general" "igpu_desiredgov" 'performance'
    crudini --set "$APPLICATION_INI" "general" "igpu_power_threshold" '-1'
    crudini --set "$APPLICATION_INI" "general" "softrealtime" 'auto'
    crudini --set "$APPLICATION_INI" "general" "renice" '5'

    update_gamemode_service

    echo "Adding $USER to group gamemode > permission to alter cpu governor"
    sudo usermod -aG gamemode $USER

    echo -e "${YELLOW}Custom optimizations added to gamemode${NC}"
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
}

function perform_check() {
    package_is_installed=$(package_is_installed "$APPLICATION_ID")

    if [ "$package_is_installed" -eq 1 ]; then
        if [ "$(check_params_exist)" = 0 ]; then
            package_is_installed=0
        fi
    fi
    echo "$package_is_installed"
}

function update_gamemode_service() {
    echo "Updating gamemode service > to be able to renice, avoid memory blocks"

    # 1. Create/overwrite the override.conf
    mkdir -p "$(dirname "$GAMEMODE_SERVICE_OVERRIDE_FILE")"
    echo "$GAMEMODE_SERVICE_OVERRIDE_CONTENT" > "$GAMEMODE_SERVICE_OVERRIDE_FILE"

    # 2. Give gamemoded capability to adjust scheduler if not already
    # if ! getcap "$(which gamemoded)" | grep -q cap_sys_nice; then
    #     sudo setcap 'cap_sys_nice=eip' "$(which gamemoded)"
    # fi

    # 3. Reload user systemd daemon and restart gamemoded
    systemctl --user daemon-reload
    systemctl --user restart gamemoded

    # 4. Status check
    systemctl --user status gamemoded --no-pager
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
