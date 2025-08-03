#!/bin/bash

readonly APPLICATION_NAME="ES-DE Emulation Station + ROM runner [official AppImage + official GitHub]"
readonly APPLICATION_GITLAB_API_URL="https://gitlab.com/api/v4/projects/18817634/releases" # IMPORTANT: The project ID 18817634 is for "ES-DE / ES-DE Frontend"
readonly APPLICATION_GITLAB_APPIMAGE_NAME="ES-DE_x64.AppImage"
readonly APPLICATION_FILE_NAME="esde"
readonly APPLICATION_INSTALL_PATH="$HOME/AppImages/$APPLICATION_FILE_NAME.appimage"
readonly APPLICATION_ICON_PATH="$HOME/AppImages/.icons/$APPLICATION_FILE_NAME.svg"
readonly APPLICATION_DESKTOP_FILE_LOCATION="$HOME/.local/share/applications/$APPLICATION_FILE_NAME.desktop"
readonly APPLICATION_ROM_CLONE_RUNNER_PATH="/opt/rom-clone-runner"
readonly LATEST_RELEASE_INFO=$(wget -qO- "$APPLICATION_GITLAB_API_URL" | jq -r '.[0]') # Get the first (latest) release object
readonly LATEST_VERSION_FULL=$(echo "$LATEST_RELEASE_INFO" | jq -r '.name')
readonly LATEST_VERSION=$(echo "$LATEST_VERSION_FULL" | grep -oP 'ES-DE\s+\K[\d\.]+') # Extract the version (e.g., "3.3.0") from the release name "ES-DE 3.3.0 / 3.3.0-48"
readonly APP_IMAGE_CONFIG_DESTINATION_FILE="$HOME/ES-DE/custom_systems/es_systems.xml"
readonly APPLICATION_DESKTOP_ENTRY='[Desktop Entry]
Name=ES-DE
GenericName=Gaming Frontend
Categories=Game;Emulator;
Keywords=emulator;emulation;front-end;frontend;
Exec='$APPLICATION_INSTALL_PATH'
TryExec='$APPLICATION_INSTALL_PATH'
Icon='$APPLICATION_ICON_PATH'
Terminal=false
Type=Application
StartupNotify=true
Hidden=false'

function perform_install() {
    download_and_install
    copy_config_files_from_app_image
    install_rom_wrapper
    echo "Creating Desktop Entry"
    echo "${APPLICATION_DESKTOP_ENTRY}" | tee -a "${APPLICATION_DESKTOP_FILE_LOCATION}" > /dev/null
}

function perform_uninstall() {
    rm "$APPLICATION_INSTALL_PATH"
}

function perform_check() {
    is_app_latest_version
}

function is_app_latest_version() {
    is_app_installed=0

    # Fetch the latest release information from GitLab API
    if [ -z "$LATEST_RELEASE_INFO" ] || [ "$LATEST_RELEASE_INFO" == "null" ]; then
        is_app_installed=0
    elif [ -f "$APPLICATION_INSTALL_PATH" ]; then
        # Check if ES-DE is already installed
        # Get the installed version using '--version' and parse it
        INSTALLED_VERSION_OUTPUT=$("$APPLICATION_INSTALL_PATH" --version 2>&1)
        # Extract the version (e.g., "3.2.0") from "ES-DE 3.2.0 (r48)"
        INSTALLED_VERSION=$(echo "$INSTALLED_VERSION_OUTPUT" | grep -oP 'ES-DE\s+\K[\d\.]+')

        if [ -n "$INSTALLED_VERSION" ]; then
            if [ "$LATEST_VERSION" == "$INSTALLED_VERSION" ]; then
                is_app_installed=1
            fi
        fi
    fi

    echo $is_app_installed
}

function download_and_install() {
    # Create installation directory if not exists
    mkdir -p "$(dirname "$APPLICATION_INSTALL_PATH")"

    DOWNLOAD_URL=$(echo "$LATEST_RELEASE_INFO" | jq -r --arg name "$APPLICATION_GITLAB_APPIMAGE_NAME" '.assets.links[] | select(.name == $name).direct_asset_url')
    if [ -z "$DOWNLOAD_URL" ]; then
        echo "Error: Could not find the download URL for $APPLICATION_GITLAB_APPIMAGE_NAME in the latest release."
        echo "Please verify the AppImage name and the structure of the GitLab API response for releases."
        exit 1
    fi

    echo "Latest ES-DE version available: $LATEST_VERSION (from release name: '$LATEST_VERSION_FULL')"
    echo "Download URL for latest version: $DOWNLOAD_URL"

    echo "Downloading and installing ES-DE to $APPLICATION_INSTALL_PATH..."

    # Force a time to wait "--version" to complete
    sleep 2

    # Download the AppImage and save it to the specified path
    wget -qO "$APPLICATION_INSTALL_PATH" "$DOWNLOAD_URL"

    # Check if the download was successful
    if [ $? -ne 0 ]; then
        echo "Error: The download failed."
        exit 1
    fi

    # Make the AppImage executable
    chmod +x "$APPLICATION_INSTALL_PATH"

    echo "ES-DE installation completed successfully."
    echo "You can run ES-DE using the command: $APPLICATION_INSTALL_PATH"
}

function copy_config_files_from_app_image() {
    readonly APP_IMAGE_ICON_ORIGIN_FILE="usr/share/icons/hicolor/scalable/apps/org.es_de.frontend.svg"
    # Create installation directory if not exists
    mkdir -p "$(dirname "$APPLICATION_ICON_PATH")"

    readonly APP_IMAGE_CONFIG_ORIGIN_FILE="usr/share/es-de/resources/systems/linux/es_systems.xml"
    WORK_DIR_TMP=$(mktemp -d)

    # Create destination directory if it does not exist
    mkdir -p "$(dirname "$APP_IMAGE_CONFIG_DESTINATION_FILE")"

    # Extract the AppImage
    echo "📦 Extracting AppImage..."
    cd "$WORK_DIR_TMP" || exit 1
    "$APPLICATION_INSTALL_PATH" --appimage-extract >/dev/null 2>&1

    # Copy contents
    cp "$WORK_DIR_TMP/squashfs-root/$APP_IMAGE_CONFIG_ORIGIN_FILE" "$APP_IMAGE_CONFIG_DESTINATION_FILE"
    cp "$WORK_DIR_TMP/squashfs-root/$APP_IMAGE_ICON_ORIGIN_FILE" "$APPLICATION_ICON_PATH"

    # Optional cleanup
    rm -rf "$WORK_DIR_TMP"
}

function install_rom_wrapper() {
    echo "Installing ROM Wrapper"
    sudo git clone https://github.com/evandro777/rom-clone-runner.git "${APPLICATION_ROM_CLONE_RUNNER_PATH}"
    sudo ln -s "${APPLICATION_ROM_CLONE_RUNNER_PATH}/rom_runner_wrapper.sh" "/bin/rom_runner_wrapper"
    sudo ln -s "${APPLICATION_ROM_CLONE_RUNNER_PATH}/rom_manager.sh" "/bin/rom_manager"
    "$APPLICATION_ROM_CLONE_RUNNER_PATH/apply_rom_runner_in_es-de.sh" "$APP_IMAGE_CONFIG_DESTINATION_FILE"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
