#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/includes/essentials.sh"
. "$DIR/includes/root_restrict_but_sudo.sh"

#queryApp
#$1: key (string)
#Example:
#	queryApp "vlc"
queryApp() {
    local app_key=$1
    local status=${apps["${app_key}, status"]}
    local action=${apps["${app_key}, action"]}
    local name=${apps["${app_key}, name"]}
    local extra_actions=${apps["${app_key}, extra_actions"]}
    local checkbox="[ ]"

    if [ "$status" != "$action" ]; then
        checkbox="[ ]"
    else
        checkbox="[x]"
    fi

    if [ "$status" == "Install" ]; then
        extra_options=""
        if [ -n "$extra_actions" ]; then
            extra_options=" [Extra options: $extra_actions]"
        fi
        echo -e "$checkbox ${app_key}: ${YELLOW}${status}${NC} $name?$extra_options"
    elif [ "$status" == "Uninstall" ]; then
        echo -e "$checkbox ${app_key}: ${RED}${status}${NC} $name?"
    else
        echo "Invalid status"
    fi
}

#queryAppMenu
#$1: key (string)
#Example:
#	queryApp "vlc"
queryAppMenu() {
    local app_key=$1
    local status=${apps["${app_key}, status"]}
    local action=${apps["${app_key}, action"]}
    local name=${apps["${app_key}, name"]}
    local extra_actions=${apps["${app_key}, extra_actions"]}

    if [ "$status" == "Install" ] || [ "$status" == "Apply" ]; then
        extra_options=""
        if [ -n "$extra_actions" ]; then
            extra_options=" [Extra options: $extra_actions]"
        fi
        echo -e "\Zb\Z2${status}\Zn $name?$extra_options"
    elif [ "$status" == "Uninstall" ]; then
        echo -e "\Zb\Z1${status}\Zn $name?"
    else
        echo "Invalid status"
    fi
}

#Switch between Install | Uninstall
#$1: value (string)
#Example:
#	apps[vlc,action]="Install"
#	apps[vlc,action]=$(SwitchIU $apps[vlc,action])
#	the result will be "Uninstall"
SwitchIU() {
    local value="${1}"
    echo $([ "${value}" == "Install" ] && echo "Uninstall" || echo "Install")
}

echo "Loading applications info..."

#DEFAULT:
applyActions="N"

declare -A apps

#Media > Video & Movies
apps[smplayer, script]="./apps/smplayer-ppa-official.sh"
apps[smplayer, category]="Media > Video & Movies"
apps[vlc, script]="./apps/vlc.sh"
apps[vlc, category]="Media > Video & Movies"
apps[gaupol, script]="./apps/gaupol.sh"
apps[gaupol, category]="Media > Video & Movies"
apps[stremio, script]="./apps/stremio-flatpak-official.sh"
apps[stremio, category]="Media > Video & Movies"

#Media > Audio & Music
apps[spotify, script]="./apps/spotify-repo-official.sh"
apps[spotify, category]="Media > Audio & Music"
apps[clementine, script]="./apps/clementine-ppa-official.sh"
apps[clementine, category]="Media > Audio & Music"
apps[strawberry, script]="./apps/strawberry-ppa-official.sh"
apps[strawberry, category]="Media > Audio & Music"
apps[rhythmbox, script]="./apps/rhythmbox.sh"
apps[rhythmbox, category]="Media > Audio & Music"

#OS & Utilities
apps[drivers, script]="./apps/drivers.sh"
apps[drivers, category]="OS & Utilities"
apps[variety, script]="./apps/variety-ppa-official.sh"
apps[variety, category]="OS & Utilities"
apps[seven_conky, script]="./apps/seven-conky-github-official.sh"
apps[seven_conky, category]="OS & Utilities"
apps[cpux, script]="./apps/cpu-x.sh"
apps[cpux, category]="OS & Utilities"
apps[xed_settings, script]="./apps/xed-settings.sh"
apps[xed_settings, category]="OS & Utilities"
apps[gnome_settings_show_startup_apps, script]="./apps/gnome-settings-show-all-startup-apps.sh"
apps[gnome_settings_show_startup_apps, category]="OS & Utilities"
apps[gnome_terminal_settings, script]="./apps/gnome-terminal-settings.sh"
apps[gnome_terminal_settings, category]="OS & Utilities"
apps[mint_cinnamon_setting_wallpaper, script]="./apps/ibus.sh"
apps[mint_cinnamon_setting_wallpaper, category]="OS & Utilities"
apps[settings_fstab_noatime, script]="./apps/settings-fstab-noatime.sh"
apps[settings_fstab_noatime, category]="OS & Utilities"

#Office & Productivity
apps[libreoffice_ppa, script]="./apps/libreoffice-ppa-official.sh"
apps[libreoffice_ppa, category]="Office & Productivity"
apps[libreoffice, script]="./apps/libreoffice-flatpak-official.sh"
apps[libreoffice, category]="Office & Productivity"
apps[onlyoffice, script]="./apps/onlyoffice-flatpak-official.sh"
apps[onlyoffice, category]="Office & Productivity"
apps[thunderbird, script]="./apps/thunderbird.sh"
apps[thunderbird, category]="Office & Productivity"
apps[flameshot, script]="./apps/flameshot.sh"
apps[flameshot, category]="Office & Productivity"
apps[copyq, script]="./apps/copyq-ppa-official.sh"
apps[copyq, category]="Office & Productivity"
apps[dropbox, script]="./apps/dropbox.sh"
apps[dropbox, category]="Office & Productivity"

#Security & Privacy
apps[keepassxc, script]="./apps/keepassxc-flatpak-official.sh"
apps[keepassxc, category]="Security & Privacy"
apps[flatseal, script]="./apps/flatseal-flatpak-official.sh"
apps[flatseal, category]="Security & Privacy"

#File Sharing
apps[qbittorrent, script]="./apps/qbittorrent-ppa-official.sh"
apps[qbittorrent, category]="File Sharing"
apps[transmission, script]="./apps/transmission.sh"
apps[transmission, category]="File Sharing"

#Web Browsers & Chat
apps[chrome, script]="./apps/chrome-repo-official.sh"
apps[chrome, category]="Web Browsers & Chat"
apps[firefox_setting, script]="./apps/firefox-settings.sh"
apps[firefox_setting, category]="Web Browsers & Chat"
apps[zoom, script]="./apps/zoom-deb-official.sh"
apps[zoom, category]="Web Browsers & Chat"
apps[discord, script]="./apps/discord-flatpak-unofficial.sh"
apps[discord, category]="Web Browsers & Chat"

#Development
apps[ohmyzsh, script]="./apps/zsh-OhMyZsh-Powerlevel10k.sh"
apps[ohmyzsh, category]="Development"
apps[vscode, script]="./apps/vscode-repo-official.sh"
apps[vscode, category]="Development"
apps[dbeaver, script]="./apps/dbeaver-ppa-official.sh"
apps[dbeaver, category]="Development"
apps[dbeaver_flatpak, script]="./apps/dbeaver-flatpak-unofficial.sh"
apps[dbeaver_flatpak, category]="Development"
apps[httpie, script]="./apps/httpie.sh"
apps[httpie, category]="Development"
apps[meld, script]="./apps/meld.sh"
apps[meld, category]="Development"
apps[docker, script]="./apps/docker-repo-official.sh"
apps[docker, category]="Development"
apps[insomnia, script]="./apps/insomnia-ppa-official.sh"
apps[insomnia, category]="Development"

#Games
apps[steam, script]="./apps/steam.sh"
apps[steam, category]="Games"
apps[lutris, script]="./apps/lutris-flatpak-official.sh"
apps[lutris, category]="Games"
apps[gamemode, script]="./apps/gamemode.sh"
apps[gamemode, category]="Games"
apps[openrgb, script]="./apps/openrgb-flatpak-unofficial.sh"
apps[openrgb, category]="Games"
apps[protonup_qt, script]="./apps/protonup_qt-flatpak-official.sh"
apps[protonup_qt, category]="Games"
apps[xpad_driver, script]="./apps/gamepad-xpad-driver-unofficial-git.sh"
apps[xpad_driver, category]="Games"

if [[ $DESKTOP_SESSION == "cinnamon" ]]; then
    apps[mint_cinnamon_setting_startup_bluetooth, script]="./apps/mint-cinnamon/mint-cinnamon-settings-startup-bluetooth.sh"
    apps[mint_cinnamon_setting_startup_bluetooth, category]="OS > Mint Cinnamon"
    apps[mint_cinnamon_setting_startup_accessibility, script]="./apps/mint-cinnamon/mint-cinnamon-settings-startup-accessibility.sh"
    apps[mint_cinnamon_setting_startup_accessibility, category]="OS > Mint Cinnamon"
    apps[mint_cinnamon_setting_wallpaper, script]="./apps/mint-cinnamon/mint-cinnamon-settings-wallpapers.sh"
    apps[mint_cinnamon_setting_wallpaper, category]="OS > Mint Cinnamon"
    apps[mint_cinnamon_setting_startup_redshift, script]="./apps/mint-cinnamon/mint-cinnamon-settings-startup-redshift.sh"
    apps[mint_cinnamon_setting_startup_redshift, category]="OS > Mint Cinnamon"
    apps[mint_cinnamon_setting_customize, script]="./apps/mint-cinnamon/mint-cinnamon-settings-customize.sh"
    apps[mint_cinnamon_setting_customize, category]="OS > Mint Cinnamon"
    apps[mint_cinnamon_setting_privacy, script]="./apps/mint-cinnamon/mint-cinnamon-settings-privacy-remember-recent-files.sh"
    apps[mint_cinnamon_setting_privacy, category]="OS > Mint Cinnamon"
fi

# Loop for setting dynamically install status and default action
for key in "${!apps[@]}"; do
    if [[ $key =~ ^([a-z_]+)[[:space:]]*,[[:space:]]*script$ ]]; then
        app_name="${BASH_REMATCH[1]}"

        status=$(${apps["$key"]} check)

        if [ "$status" -eq 0 ]; then
            app_status="Install"
        elif [ "$status" -eq 1 ]; then
            app_status="Uninstall"
        elif [ "$status" -eq 2 ]; then
            app_status="Apply"
        elif [ "$status" -eq 3 ]; then
            unset apps["$key"]
            unset apps["${app_name}, category"]
            continue
        else
            echo "Invalid status value for $app_name: $status"
            exit 1
        fi

        apps["${app_name}, name"]=$(${apps["$key"]} name)
        # apps["${app_name}, status"]=$([ "$(${apps["$key"]} check)" -eq 1 ] && echo "Uninstall" || echo "Install")
        apps["${app_name}, status"]=$app_status
        apps["${app_name}, action"]=$([ "${apps["${app_name}, status"]}" == "Install" ] && echo "Uninstall" || echo "Install") # Default: Inverted value of status
        apps["${app_name}, extra_actions"]=""
    fi
done

# Debug > Show values
# for key in "${!apps[@]}"; do
#     echo "$key: ${apps[$key]}"
# done
# # OR: declare -p apps
# exit
