#!/bin/bash

#COLORS
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${ORANGE}Installing CopyQ (official PPA)${NC}"

#dbeaver Official PPA
sudo add-apt-repository -y ppa:hluk/copyq
sudo apt-get update
sudo apt install -y copyq

echo -e "Enable CopyQ autostart"
copyq config autostart true

if [ "$DESKTOP_SESSION" == "cinnamon" ]; then
    echo -e "${ORANGE}CopyQ Applying shortcut: CTRL + ALT + V${NC}"
    
    lastId=$(GetKeybindingLastId)
    newId=$(($lastId + 1))
    newCustomId="custom${newId}"
    
    if [ -z "$(KeybindingExists "<Primary><Alt>v")" ]; then
        setList=$(dconf read /org/cinnamon/desktop/keybindings/custom-list | sed -r "s/\[/['${newCustomId}', /g") # Insert new id on first one
        #setList=$(dconf read /org/cinnamon/desktop/keybindings/custom-list | sed -r "s/']/', '${newCustomId}']/g") # Insert new id on last one
        dconf write /org/cinnamon/desktop/keybindings/custom-list "${setList}"
        gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ name "CopyQ"
        gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ command "copyq menu"
        gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ binding '["<Primary><Alt>v"]'
    else
        echo -e "${ORANGE}Shortcut was already been using${NC}"
    fi
fi
