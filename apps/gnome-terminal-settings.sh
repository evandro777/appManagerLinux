#!/bin/bash

readonly APPLICATION_NAME="GNOME terminal > Fonts (for OhMyZsh + PowerLevel10k) + New profiles: Dracula + Green"
readonly PROFILE_GREEN_HASH="5fb53c50-40ea-4836-9958-956ee13d6ed9"
readonly PROFILE_DRACULA_HASH="765e07a8-5a35-408a-b25c-630650a6c695"

# Check if profile exists
# $1: profile_hash
function profile_exists() {
    local profile_name="$1"
    #list_profile="$(dconf list /org/gnome/terminal/legacy/profiles:/:${profile_name}/)"
    list_profile="$(dconf read /org/gnome/terminal/legacy/profiles:/list | grep "${profile_name}")"
    #return $([ "$list_profile" ] && true || false)
    echo "$list_profile"
}

# Save Profile (create or update)
# $1: profile_hash
# $2: profile_name
function save_profile() {
    local new_profile_hash="$1"
    local profile_name="$2"
    #Check if profile doesn't exists and create a new one
    #if ! profile_exists $new_profile_hash ; then
    if [ -z "$(profile_exists "$new_profile_hash")" ]; then
        local set_list=$(dconf read /org/gnome/terminal/legacy/profiles:/list | sed -r "s/']/', '${new_profile_hash}']/g")
        if [ -z "$set_list" ]; then # if set_list is empty
            # Create list with the default profile
            # dconf write /org/gnome/terminal/legacy/profiles:/list "[$(dconf read /org/gnome/terminal/legacy/profiles:/default)]"
            dconf write /org/gnome/terminal/legacy/profiles:/list "['$new_profile_hash']"
        else
            # Add a new profile
            local set_list=$(dconf read /org/gnome/terminal/legacy/profiles:/list | sed -r "s/']/', '${new_profile_hash}']/g")
            dconf write /org/gnome/terminal/legacy/profiles:/list "${set_list}"
        fi
    fi
    dconf write /org/gnome/terminal/legacy/profiles:/:"${new_profile_hash}"/visible-name "'${profile_name}'"
}

# Create/Update Green Profile
function create_green_profile() {
    save_profile "${PROFILE_GREEN_HASH}" "Green"
    green_theme_params="[/]
        background-color='rgb(1,11,6)'
        use-theme-colors=false
        use-system-font=false
        font='MesloLGS NF 11'
        palette=['rgb(0,0,0)', 'rgb(205,0,0)', 'rgb(0,205,0)', 'rgb(205,205,0)', 'rgb(0,0,238)', 'rgb(205,0,205)', 'rgb(0,205,205)', 'rgb(229,229,229)', 'rgb(127,127,127)', 'rgb(255,0,0)', 'rgb(0,255,0)', 'rgb(255,255,0)', 'rgb(92,92,255)', 'rgb(255,0,255)', 'rgb(0,255,255)', 'rgb(255,255,255)']
        foreground-color='rgb(14,234,120)'"
    dconf load /org/gnome/terminal/legacy/profiles:/:"${PROFILE_GREEN_HASH}"/ <<< "${green_theme_params}"
    #dconf load /org/gnome/terminal/legacy/profiles:/:"${PROFILE_GREEN_HASH}"/ < dconf/terminal-settings.dconf
}

# Create/Update Dracula Profile
# $1: profile_name
function create_dracula_profile() {
    local profile_name="$1"
    save_profile "${PROFILE_DRACULA_HASH}" "${profile_name}"
    # Set font
    dconf write /org/gnome/terminal/legacy/profiles:/:"${PROFILE_DRACULA_HASH}"/use-system-font false
    dconf write /org/gnome/terminal/legacy/profiles:/:"${PROFILE_DRACULA_HASH}"/font "'MesloLGS NF 11'"
}

# Download & Install Dracula theme
# $1: profile_name
function install_dracula_theme() {
    local profile_name="$1"
    dracula_folder="/tmp/gnome-terminal-dracula/"
    wget --no-verbose --timestamping --directory-prefix="${dracula_folder}" https://github.com/dracula/gnome-terminal/archive/master.zip
    echo "Extracting ${dracula_folder}master.zip ..."
    unzip -o -q "${dracula_folder}master.zip" -d "${dracula_folder}"

    #Alternative works, but have to take care of directory
    #wget -qO- https://github.com/dracula/gnome-terminal/archive/master.zip | busybox unzip -d "/tmp/" -

    #A dircolors adapted to solarized can be automatically downloaded.
    #--install-dircolors: Download seebi' dircolors-solarized: https://github.com/seebi/dircolors-solarized
    #--skip-dircolors: [DEFAULT] I don't need any dircolors.
    "${dracula_folder}gnome-terminal-master/"./install.sh --scheme="$profile_name" --profile="$profile_name" --skip-dircolors
}

# Download & install fonts
function install_fonts() {
    sudo apt-get install -y fontconfig
    wget --no-verbose --timestamping --directory-prefix="${HOME}/.local/share/fonts/" "https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf"
    wget --no-verbose --timestamping --directory-prefix="${HOME}/.local/share/fonts/" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
    wget --no-verbose --timestamping --directory-prefix="${HOME}/.local/share/fonts/" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
    wget --no-verbose --timestamping --directory-prefix="${HOME}/.local/share/fonts/" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
    wget --no-verbose --timestamping --directory-prefix="${HOME}/.local/share/fonts/" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
    fc-cache -vf ~/.local/share/fonts/
    wget --no-verbose --timestamping --directory-prefix="${HOME}/.config/fontconfig/conf.d/" "https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf"
}

function perform_install() {
    echo -e "Installing MesloLGS font for Powerlevel10k"
    install_fonts

    echo -e "Creating Green profile theme"
    create_green_profile

    dracula_profile_name="Dracula"
    echo -e "Creating default profile > Dracula"
    create_dracula_profile "${dracula_profile_name}"

    echo -e "Downloading & Installing Dracula Theme"
    install_dracula_theme "${dracula_profile_name}"

    echo -e "Setting default profile > Dracula"
    dconf write /org/gnome/terminal/legacy/profiles:/default "'${PROFILE_DRACULA_HASH}'"
}

function perform_uninstall() {
    echo -e "${RED}Resetting settings $APPLICATION_NAME...${NC}"
    dconf reset -f /org/gnome/terminal/legacy/profiles:/
}

function perform_check() {
    package_is_installed=1 # Default installed > If find any situation below, will result in "Not installed"
    if [ -z "$(profile_exists "$PROFILE_DRACULA_HASH")" ]; then
        package_is_installed=0
    elif [ -z "$(profile_exists "$PROFILE_GREEN_HASH")" ]; then
        package_is_installed=0
    elif [ ! -e "${HOME}/.config/fontconfig/conf.d/10-powerline-symbols.conf" ]; then
        package_is_installed=0
    fi
    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
