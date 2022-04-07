#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color
echo -e "${ORANGE}Configure Gnome Terminal${NC}"

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/essentials.sh"
. "../includes/root_restrict.sh"

#GNOME TERMINAL - CONFIG

#Check if profile exists
#$1: profile_hash
function ProfileExists(){
	local profileName="$1"
	#listProfile="$(dconf list /org/gnome/terminal/legacy/profiles:/:${profileName}/)"
	listProfile="$(dconf read /org/gnome/terminal/legacy/profiles:/list | grep ${profileName} )"
	#return $([ "$listProfile" ] && true || false)
	echo "$listProfile"
}

#Save Profile (create or update)
#$1: profile_hash
#$2: profile_name
function SaveProfile(){
	local newProfileHash="$1"
	local profileName="$2"
	#Check if profile doesn't exists and create a new one
	#if ! ProfileExists $newProfileHash ; then
	echo $(ProfileExists $newProfileHash)
	if [ -z "$(ProfileExists $newProfileHash)" ]; then
		local setList=$(dconf read /org/gnome/terminal/legacy/profiles:/list | sed -r "s/']/', '${newProfileHash}']/g")
		dconf write /org/gnome/terminal/legacy/profiles:/list "${setList}"
	fi
	dconf write /org/gnome/terminal/legacy/profiles:/:"${newProfileHash}"/visible-name "'${profileName}'"
}



#ADD GREEN THEME
newProfileHash="5fb53c50-40ea-4836-9958-956ee13d6ed9"
SaveProfile "${newProfileHash}" "Green"
greenThemeParams="[/]
background-color='rgb(1,11,6)'
use-theme-colors=false
palette=['rgb(0,0,0)', 'rgb(205,0,0)', 'rgb(0,205,0)', 'rgb(205,205,0)', 'rgb(0,0,238)', 'rgb(205,0,205)', 'rgb(0,205,205)', 'rgb(229,229,229)', 'rgb(127,127,127)', 'rgb(255,0,0)', 'rgb(0,255,0)', 'rgb(255,255,0)', 'rgb(92,92,255)', 'rgb(255,0,255)', 'rgb(0,255,255)', 'rgb(255,255,255)']
foreground-color='rgb(14,234,120)'"
dconf load /org/gnome/terminal/legacy/profiles:/:"${newProfileHash}"/ <<< "${greenThemeParams}"
#dconf load /org/gnome/terminal/legacy/profiles:/:"${newProfileHash}"/ < dconf/terminal-settings.dconf



#ADD DRACULA THEME
newProfileHash="765e07a8-5a35-408a-b25c-630650a6c695"
SaveProfile "${newProfileHash}" "Dracula"

#Set default
dconf write /org/gnome/terminal/legacy/profiles:/default "'${newProfileHash}'"

draculaFolder="/tmp/gnome-terminal-dracula/"
wget --directory-prefix="${draculaFolder}" https://github.com/dracula/gnome-terminal/archive/master.zip
unzip -o "${draculaFolder}master.zip" -d "${draculaFolder}"

#Alternative works, but have to take care of directory
#wget -qO- https://github.com/dracula/gnome-terminal/archive/master.zip | busybox unzip -d "/tmp/" -

#A dircolors adapted to solarized can be automatically downloaded.
#--install-dircolors: Download seebi' dircolors-solarized: https://github.com/seebi/dircolors-solarized
#--skip-dircolors: [DEFAULT] I don't need any dircolors.
"${draculaFolder}gnome-terminal-master/"./install.sh --scheme=Dracula --profile=Dracula --skip-dircolors
