#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Kitty [distro repository]"
readonly APPLICATION_ID="kitty"
readonly APPLICATION_CONFIG_PATH="${HOME}/.config/kitty"
readonly APPLICATION_CONFIG_FILE="${APPLICATION_CONFIG_PATH}/kitty.conf"
readonly DRACULA_THEME_URL="https://github.com/dracula/kitty/archive/master.zip"

function set_kitty_config_value() {
    local setting="$1"
    local value="$2"

    if grep -qE "^[[:space:]]*${setting}([[:space:]]|$)" "$APPLICATION_CONFIG_FILE"; then
        sed -i -E "s|^[[:space:]]*${setting}([[:space:]].*)?$|${setting} ${value}|" "$APPLICATION_CONFIG_FILE"
    else
        printf '%s %s\n' "$setting" "$value" >> "$APPLICATION_CONFIG_FILE"
    fi
}

function perform_install() {
    package_install "$APPLICATION_ID"

    local theme_download_dir
    theme_download_dir="$(mktemp -d)" || return 1
    if ! wget --quiet --output-document="${theme_download_dir}/dracula.zip" "$DRACULA_THEME_URL"; then
        rm -rf "$theme_download_dir"
        return 1
    fi
    if ! unzip -q "${theme_download_dir}/dracula.zip" -d "$theme_download_dir"; then
        rm -rf "$theme_download_dir"
        return 1
    fi

    mkdir -p "$APPLICATION_CONFIG_PATH" || return 1
    cp "${theme_download_dir}/kitty-master/dracula.conf" "${theme_download_dir}/kitty-master/diff.conf" "$APPLICATION_CONFIG_PATH/" || return 1
    rm -rf "$theme_download_dir"

    touch "$APPLICATION_CONFIG_FILE" || return 1
    if ! grep -qxF 'include dracula.conf' "$APPLICATION_CONFIG_FILE"; then
        printf '%s\n' 'include dracula.conf' >> "$APPLICATION_CONFIG_FILE"
    fi
    set_kitty_config_value font_family "MesloLGS NF"
    set_kitty_config_value font_size 11
    set_kitty_config_value remember_window_size no
    set_kitty_config_value initial_window_width 900
    set_kitty_config_value initial_window_height 600
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
}

function perform_check() {
    if [ "$(package_is_installed "$APPLICATION_ID")" -eq 1 ] &&
        [ -f "$APPLICATION_CONFIG_FILE" ] &&
        [ -f "${APPLICATION_CONFIG_PATH}/dracula.conf" ] &&
        grep -qxF 'include dracula.conf' "$APPLICATION_CONFIG_FILE"; then
        echo 1
    else
        echo 0
    fi
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
