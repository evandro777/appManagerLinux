#!/bin/bash

readonly APPLICATION_NAME="XED > Settings > dracula theme +custom settings"
readonly THEME_DRACULA_FOLDER="/usr/share/gtksourceview-3.0/styles"
readonly THEME_DRACULA_FILE="${THEME_DRACULA_FOLDER}/dracula.xml"

function perform_install() {
    echo -e "${YELLOW}Applying $APPLICATION_NAME...${NC}"
    echo -e "${YELLOW}Installing dracula theme for XED${NC}"
    ## Download & create folder and overwrite file
    sudo wget --no-verbose --timestamping --directory-prefix="${THEME_DRACULA_FOLDER}" https://raw.githubusercontent.com/dracula/gedit/master/dracula.xml
    sudo cp "${THEME_DRACULA_FILE}" /usr/share/gtksourceview-4/styles/

    echo "Applying custom settings for XED"
    gsettings set org.x.editor.preferences.editor highlight-current-line true
    gsettings set org.x.editor.preferences.editor display-line-numbers true
    gsettings set org.x.editor.preferences.editor bracket-matching true
    #gsettings set org.x.editor.preferences.editor insert-spaces false
    gsettings set org.x.editor.preferences.editor auto-indent true
    gsettings set org.x.editor.preferences.editor draw-whitespace true
    gsettings set org.x.editor.preferences.editor draw-whitespace-leading true
    gsettings set org.x.editor.preferences.editor draw-whitespace-trailing true
    gsettings set org.x.editor.preferences.editor prefer-dark-theme true
    gsettings set org.x.editor.preferences.editor scheme "dracula"
    gsettings set org.x.editor.plugins active-plugins '["sort", "modelines", "filebrowser", "wordcompletion", "textsize", "taglist", "docinfo", "time", "spell"]'
}

function perform_uninstall() {
    echo -e "${RED}Resetting $APPLICATION_NAME...${NC}"
    gsettings reset-recursively org.x.editor.preferences.editor
    gsettings reset org.x.editor.plugins active-plugins
}

function perform_check() {
    package_is_installed=0
    if [ -f "${THEME_DRACULA_FILE}" ]; then
        package_is_installed=1
    fi
    echo $package_is_installed
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
