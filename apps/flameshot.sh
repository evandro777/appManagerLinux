#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color
echo -e "${ORANGE}Installing Flameshot${NC}"

# Get Last Id From Keybinding
function GetKeybindingLastId(){
    local listId=$(dconf read /org/cinnamon/desktop/keybindings/custom-list)
    if [ "$listId" == "" ]; then
        listId="[]"
    fi
    
    # Need to get first and last sequence, because sometimes the bigger id is the first one, sometimes is the last one
    # Get first sequence
    firstId=${listId:2:10} # Get 10 first chars (except first 2)
    firstId=$(echo "${firstId}" | sed 's/[^0-9]*//g') # Remove all except numbers
    
    # Get last sequence
    lastId=${listId::-2} # Remove 2 last chars
    lastId=${listId: -7} # Get 7 last chars
    lastId=$(echo "${lastId}" | sed 's/[^0-9]*//g') # Remove all except numbers

    if (( $firstId > $lastId )); then
        id=$firstId
    else
        id=$lastId
    fi
    
    if [ "$id" == "" ]; then
        id="-1" # Force -1 (doesn't exist the id). So the next id will be 0
    fi
    echo "$id"
}

# Return string if keybiding is found
#$1: keybinding (example: <Super>Print)
function KeybindingExists(){
    local keyBinding="$1"
    local return=$(dconf dump /org/cinnamon/desktop/keybindings/ | grep "${keyBinding}")
    echo "$return"
}

apt update
sudo apt install -y flameshot

if [ "$DESKTOP_SESSION" == "cinnamon" ]; then
	echo -e "${ORANGE}Applying shortcut: Super + Print Screen${NC}"
	
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
