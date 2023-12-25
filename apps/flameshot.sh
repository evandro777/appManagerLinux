#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/essentials.sh"
. "../includes/root_restrict_but_sudo.sh"

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Flameshot [+custom config]${NC}"

sudo apt-get update
sudo apt-get install -y flameshot

flameShotIniPath="${HOME}/.config/flameshot/"
mkdir -p "${flameShotIniPath}"

flameShotIniFile="${flameShotIniPath}flameshot.ini"
touch "${flameShotIniFile}"

echo -e "${ORANGE}Flameshot > Disable welcome message${NC}"
crudini --set "${flameShotIniFile}" General showStartupLaunchMessage "false"

if [ "$DESKTOP_SESSION" == "cinnamon" ]; then
    echo -e "${ORANGE}Flameshot > Applying shortcut: Super + Print Screen${NC}"

    lastId=$(GetKeybindingLastId)
    newId=$(($lastId + 1))
    newCustomId="custom${newId}"

    if [ -z "$(KeybindingExists "<Super>Print")" ]; then
        setList=$(dconf read /org/cinnamon/desktop/keybindings/custom-list | sed -r "s/\[/['${newCustomId}', /g") # Insert new id on first one
        #setList=$(dconf read /org/cinnamon/desktop/keybindings/custom-list | sed -r "s/']/', '${newCustomId}']/g") # Insert new id on last one
        dconf write /org/cinnamon/desktop/keybindings/custom-list "${setList}"
        gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ name "Flameshot"
        gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ command "flameshot gui"
        gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ binding '["<Super>Print"]'
    else
        echo -e "${ORANGE}Shortcut was already been using${NC}"
    fi
fi
