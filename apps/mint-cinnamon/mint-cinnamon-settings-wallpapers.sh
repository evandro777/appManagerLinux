#!/bin/bash

readonly APPLICATION_NAME="Mint Cinnamon > Settings > +Wallpapers +setting random rotation"
readonly APPLICATION_ID="mint-backgrounds-*"

#Set wallpaper slideshow, create folder unifying all mint wallpapers for slideshow
#$3: filename
function set_wallpaper_slideshow() {
    background_folder="/usr/share/backgrounds"

    background_config="/home/seven/.config/cinnamon/backgrounds/user-folders.lst"

    background_new_folder="${background_folder}/allmint"
    sudo mkdir -p "$background_new_folder"
    original_folder="${PWD}"
    cd "$background_folder" || return
    sudo find linux* -name "*.??g" -exec ln -s -f $background_folder/{} allmint/ \;
    cd "$original_folder" || return

    # Verify if $background_config exists and folder is already in $background_config
    if [ ! -e "$background_config" ] || ! grep -Fxq "$background_new_folder" "$background_config"; then
        echo "$background_new_folder" >> "$background_config"
    fi

    echo "Setting allmint folder for wallpapers and turn on slideshow on random order"
    gsettings set org.cinnamon.desktop.background.slideshow image-source "directory://${background_new_folder}"
    gsettings set org.cinnamon.desktop.background.slideshow delay 7
    gsettings set org.cinnamon.desktop.background.slideshow slideshow-enabled true
    gsettings set org.cinnamon.desktop.background.slideshow random-order true
}

function perform_install() {
    package_install "$APPLICATION_ID"
    if is_process_running "variety"; then
        echo -e "${RED}Skipping setting > ${NC}${YELLOW}Variety (wallpaper changer) is detected and it might conflict with cinnamon wallpaper rotation${NC}"
        exit 0
    fi
    set_wallpaper_slideshow
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
}

function perform_check() {
    packages_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/mint-cinnamon-helper.sh" # Include file
. "$DIR/../../includes/header_packages.sh"

exit 0
