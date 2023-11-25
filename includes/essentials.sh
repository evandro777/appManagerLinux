#!/bin/bash

#FOLLOW SYMLINK / USE SCRIPT DIRECTORY
#MAY CAUSE PROBLEM WHEN EXECUTING FROM OTHER DIRECTORYS. BETTER BE THE LAST ONE TO EXECUTE
cd "$(dirname "$(realpath "$0")")"

#COLORS
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color / Reset color




# Reset
Color_Off="\[\033[0m\]"       # Text Reset

# Regular Colors
Black="\[\033[0;30m\]"        # Black
Red="\[\033[0;31m\]"          # Red
Green="\[\033[0;32m\]"        # Green
Yellow="\[\033[0;33m\]"       # Yellow
Blue="\[\033[0;34m\]"         # Blue
Purple="\[\033[0;35m\]"       # Purple
Cyan="\[\033[0;36m\]"         # Cyan
White="\[\033[0;37m\]"        # White

# Bold
BBlack="\[\033[1;30m\]"       # Black
BRed="\[\033[1;31m\]"         # Red
BGreen="\[\033[1;32m\]"       # Green
BYellow="\[\033[1;33m\]"      # Yellow
BBlue="\[\033[1;34m\]"        # Blue
BPurple="\[\033[1;35m\]"      # Purple
BCyan="\[\033[1;36m\]"        # Cyan
BWhite="\[\033[1;37m\]"       # White

# Underline
UBlack="\[\033[4;30m\]"       # Black
URed="\[\033[4;31m\]"         # Red
UGreen="\[\033[4;32m\]"       # Green
UYellow="\[\033[4;33m\]"      # Yellow
UBlue="\[\033[4;34m\]"        # Blue
UPurple="\[\033[4;35m\]"      # Purple
UCyan="\[\033[4;36m\]"        # Cyan
UWhite="\[\033[4;37m\]"       # White

# Background
On_Black="\[\033[40m\]"       # Black
On_Red="\[\033[41m\]"         # Red
On_Green="\[\033[42m\]"       # Green
On_Yellow="\[\033[43m\]"      # Yellow
On_Blue="\[\033[44m\]"        # Blue
On_Purple="\[\033[45m\]"      # Purple
On_Cyan="\[\033[46m\]"        # Cyan
On_White="\[\033[47m\]"       # White

# High Intensty
IBlack="\[\033[0;90m\]"       # Black
IRed="\[\033[0;91m\]"         # Red
IGreen="\[\033[0;92m\]"       # Green
IYellow="\[\033[0;93m\]"      # Yellow
IBlue="\[\033[0;94m\]"        # Blue
IPurple="\[\033[0;95m\]"      # Purple
ICyan="\[\033[0;96m\]"        # Cyan
IWhite="\[\033[0;97m\]"       # White

# Bold High Intensty
BIBlack="\[\033[1;90m\]"      # Black
BIRed="\[\033[1;91m\]"        # Red
BIGreen="\[\033[1;92m\]"      # Green
BIYellow="\[\033[1;93m\]"     # Yellow
BIBlue="\[\033[1;94m\]"       # Blue
BIPurple="\[\033[1;95m\]"     # Purple
BICyan="\[\033[1;96m\]"       # Cyan
BIWhite="\[\033[1;97m\]"      # White

# High Intensty backgrounds
On_IBlack="\[\033[0;100m\]"   # Black
On_IRed="\[\033[0;101m\]"     # Red
On_IGreen="\[\033[0;102m\]"   # Green
On_IYellow="\[\033[0;103m\]"  # Yellow
On_IBlue="\[\033[0;104m\]"    # Blue
On_IPurple="\[\033[10;95m\]"  # Purple
On_ICyan="\[\033[0;106m\]"    # Cyan
On_IWhite="\[\033[0;107m\]"   # White



#Insert or update settings
#Example: SetProperty "X-GNOME-Autostart-enabled" false "${HOME}/.config/autostart/mintwelcome.desktop"
#$1: param
#$2: value
#$3: file
function SetProperty(){
    local param="${1}="
    local value="${1}=${2}"
    local fileLocation="${3}"
    SearchReplaceOrCreate "$param" "$value" "$fileLocation"
}

#Search & Replace or create line
#Example: SearchReplaceOrCreate "X-GNOME-Autostart-enabled=" "X-GNOME-Autostart-enabled=false" "${HOME}/.config/autostart/mintwelcome.desktop"
#$1: param
#$2: value
#$3: file
function SearchReplaceOrCreate(){
    local param="${1}"
    local value="${2}"
    local fileLocation="${3}"
    
    if ! grep -q "${param}" "${fileLocation}"; then
        #insert
        echo "${value}" >> "${fileLocation}"
    else
        #update
        sed -i s/"${param}".*$/"${value}"/ "${fileLocation}"
    fi
}

#Ps.: Force remove white spaces " = ", happens when creating a new file, when editing a file that already doesn't have, it isn't needed
#Force remove white spaces " = " between key and value
#Example: TrimPropertys "${HOME}/.config/autostart/mintwelcome.desktop"
#$1: file
function TrimPropertys(){
    local fileLocation="${1}"
    
    sed -i -r "s/(\S*)\s*=\s*(.*)/\1=\2/g" "${fileLocation}"
}

function CommandDependency(){
    local commandName="${1}"
    command -v "$commandName" >/dev/null 2>&1 || { echo -e >&2 "${RED}$commandName${NC} is required but it's not installed! Aborting."; exit 1; }
}

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
    lastId=${lastId: -7} # Get 7 last chars
    lastId=$(echo "${lastId}" | sed 's/[^0-9]*//g') # Remove all except numbers
    
    if (( firstId > lastId )); then
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
