#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/essentials.sh"
. "../includes/root_restrict_but_sudo.sh"

#Change startup apps settings
#$1: param (search)
#$2: value to set
#$3: file location
#Example:
#StartupAppSetting "X-GNOME-Autostart-enabled" false "${HOME}/.config/autostart/${1}.desktop"
function StartupAppSetting(){
	#BOTH ARE WORKING ALTERNATIVES
	#crudini --set "${3}" "Desktop Entry" "${1}" "${2}"
	SetProperty "${1}" "${2}" "${3}"
}

#Disable autostart
#$3: filename
function DisableAutoStart(){
	cp "/etc/xdg/autostart/${1}.desktop" "${HOME}/.config/autostart/"
	StartupAppSetting "X-GNOME-Autostart-enabled" false "${HOME}/.config/autostart/${1}.desktop"
}

####################
##### CINNAMON #####
####################
echo -e "${Orange}Cinnamon Desktop${NC}"

###############################
##### STARTUP > QUESTIONS #####
###############################
#bluetooth
while true; do
	echo -e "${RED}Disable startup${NC} bluetooth? (Y/N): "
	read -p "" bluetooth_disable
	case $bluetooth_disable in
		[YyNn]* ) break;;
	esac
done

#notification calendar
#while true; do
#	echo -e "${RED}Disable startup${NC} calendar/events notifications/alarms? (Y/N): "
#	read -p "" evolution_notify_disable
#	case $evolution_notify_disable in
#		[YyNn]* ) break;;
#	esac
#done

#Trayicon for NVIDIA Prime
while true; do
	echo -e "${RED}Disable startup${NC} trayicon NVIDIA Prime (can be accessed through the System Settings)? (Y/N): "
	read -p "" nvidia_trayicon_disable
	case $nvidia_trayicon_disable in
		[YyNn]* ) break;;
	esac
done

#Update
#while true; do
#	echo -e "${RED}Disable startup${NC} update manager? (Y/N): "
#	read -p "" update_manager_disable
#	case $update_manager_disable in
#		[YyNn]* ) break;;
#	esac
#done

#################################
##### STARTUP APPS > ENABLE #####
#################################
echo -e "${GREEN}Redshift (Blue Light Filter) > ${NC}Creating config"
#REDSHIFT > BLUELIGHT FILTER < LATITUDE LONGITUDE MIRASSOL: redshift-gtk -l -20.8136:-49.5144 -t 6000:5000
REDSHIFT_DESKTOP_CONTENT='[Desktop Entry]
Type=Application
Exec=redshift-gtk -t 6000:4500
Terminal=false
NoDisplay=false
Hidden=false
Name=Redshift
Comment=Color temperature adjustment tool
Name[en_US]=Redshift
Comment[en_US]=Color temperature adjustment tool
StartupNotify=true
Icon=redshift
X-GNOME-Autostart-Delay=3
X-GNOME-Autostart-enabled=true'

echo -e "${GREEN}Redshift (Blue Light Filter) > ${NC}Enabled autostart"

REDSHIFT_DESKTOP_FILE="${HOME}/.config/autostart/redshift-gtk.desktop"
if [ -f "$REDSHIFT_DESKTOP_FILE" ]; then
	StartupAppSetting "Hidden" false "${REDSHIFT_DESKTOP_FILE}"
	StartupAppSetting "X-GNOME-Autostart-enabled" true "${REDSHIFT_DESKTOP_FILE}"
	StartupAppSetting "Exec" "redshift-gtk -t 6000:4500" "${REDSHIFT_DESKTOP_FILE}"
else
	#CREATE FILE WITH USER PERMISSION. USING ECHO OR PRINTF DIRECTLY WILL CREATE WITH ROOT PERMISSION
	printf "${REDSHIFT_DESKTOP_CONTENT}" | tee -a "${REDSHIFT_DESKTOP_FILE}" > /dev/null
fi

##################################
##### STARTUP APPS > DISABLE #####
##################################
echo "Disable startup programs"
echo "STARTUP APPS > Which applications to start at login"
echo -e "${ORANGE}http://askubuntu.com/questions/414841/which-applications-to-start-at-login${NC}"

#AUTOSTART > DISABLE > MINT UPLOAD > DOESN'T HAVE ON MINT 19
#DisableAutoStart "mintupload"

#AUTOSTART > DISABLE > Bluetooth OBEX Agent > Allows to receive files via Bluetooth
if [[ "$bluetooth_disable" == [yY] ]]; then
	echo "Auto start > Disable > Blueberry"
	DisableAutoStart "blueberry-tray" 2>/dev/null
	DisableAutoStart "blueberry-obex-agent" 2>/dev/null
	echo "Auto start > Disable > Blueman"
	DisableAutoStart "blueman"
fi

#AUTOSTART > DISABLE > Alarm notifier for Evolution incoming events and appointments
#if [[ "$evolution_notify_disable" == [yY] ]]; then
#	DisableAutoStart "org.gnome.Evolution-alarm-notify"
#fi

#AUTOSTART > DISABLE > NVIDIA PRIME
if [[ "$nvidia_trayicon_disable" == [yY] ]]; then
	DisableAutoStart "nvidia-prime"
	DisableAutoStart "nvidia-settings-autostart"
fi

#AUTOSTART > DISABLE > UPDATE MANAGER
#if [[ "$update_manager_disable" == [yY] ]]; then
#	DisableAutoStart "mintupdate"
#fi

echo "Auto start > Disable > Mint Welcome"
DisableAutoStart "mintwelcome"

echo "Auto start > Disable > Orca Screen Reader"
DisableAutoStart "orca-autostart"

echo "Auto start > Disable > Caribou (on screen keyboard)"
DisableAutoStart "caribou-autostart"

echo "Auto start > Disable > Rename folders based on language"
DisableAutoStart "user-dirs-update-gtk"

echo "Auto start > Disable > AT SPI D-Bus Bus AT SPI stands for Assistive Technology Service Provider Interface: unwanted until you need the accessibility features"
DisableAutoStart "at-spi-dbus-bus"

#AUTOSTART > DISABLE > VNC SERVER > DOESN'T HAVE ON MINT 19
#DisableAutoStart vino-server

#FIX PERMISSIONS OF COPIED FILES
#sudo chown --recursive $SUDO_USER:$SUDO_USER ~/.config/autostart/

echo "Setting maximum compression for file-roller"
gsettings set org.gnome.FileRoller.General compression-level "maximum" # POSSIBLE VALUES: fast, normal, maximum

echo "Setting privacy > disable remembering recent files"
gsettings set org.cinnamon.desktop.privacy remember-recent-files false

#CALENDAR WIDGET > INSERT DATE
# USE > ON THE SAME FILE WILL RETURN A BLANK FILE. HAVE TO CREATE A TEMPORARY FILE, THEN RENAME/MOVE IT
#jq '.["use-custom-format"]["value"] = true' ~/.cinnamon/configs/calendar@cinnamon.org/13.json > ~/.cinnamon/configs/calendar@cinnamon.org/13.json.$$ && mv ~/.cinnamon/configs/calendar@cinnamon.org/13.json.$$ ~/.cinnamon/configs/calendar@cinnamon.org/13.json
#jq '.["custom-format"]["value"] = "%d/%m/%Y %H:%M"' ~/.cinnamon/configs/calendar@cinnamon.org/13.json > ~/.cinnamon/configs/calendar@cinnamon.org/13.json.$$ && mv ~/.cinnamon/configs/calendar@cinnamon.org/13.json.$$ ~/.cinnamon/configs/calendar@cinnamon.org/13.json

## DESKTOP

echo "Enable desktop trash icon"
gsettings set org.nemo.desktop trash-icon-visible true

echo "Notifications on the bottom side of the screen"
gsettings set org.cinnamon.desktop.notifications bottom-notifications true

## THEME > Mint-Y-Dark
echo "Apply Mint-Y-Dark theme with transparency panel"
mkdir -p "${HOME}/.themes/"
cp -r /usr/share/themes/Mint-Y-Dark/ "$HOME/.themes/Mint-Y-Dark-Transparency/" # create a new theme based on original one

# Manually look for: .menu {
# Change panel background color, and add transparency #Mint 20.x
sed -i s/"  background-color: rgba(48, 49, 48, 0.99);"$/"  background-color: rgba(0, 0, 0, 0.2);"/ "$HOME/.themes/Mint-Y-Dark-Transparency/cinnamon/cinnamon.css"

# Change panel background color, and add transparency #Mint 21.x
sed -i s/"  background-color: rgba(47, 47, 47, 0.99);"$/"  background-color: rgba(0, 0, 0, 0.2);"/ "$HOME/.themes/Mint-Y-Dark-Transparency/cinnamon/cinnamon.css"

gsettings set org.cinnamon.desktop.interface gtk-theme "Mint-Y-Dark"
gsettings set org.cinnamon.desktop.interface icon-theme "Mint-Y-Yaru"
gsettings set org.cinnamon.desktop.wm.preferences theme "Mint-Y"
#gsettings set org.cinnamon.theme name "Mint-Y-Dark" #original
gsettings set org.cinnamon.theme name "Mint-Y-Dark-Transparency" #modified with panel transparency

#DISABLE LOCK ON MONITOR OFF
#gsettings set org.cinnamon.desktop.screensaver lock-enabled false

#DISABLE LOCK ON SUSPEND
#gsettings set org.cinnamon.settings-daemon.plugins.power lock-on-suspend false

#DISABLE LOCK ON IDLE TIME
#gsettings set org.cinnamon.desktop.session idle-delay 'uint32 0'

## NOTEBOOK

echo "Notebook > Disable reverse rolling"
gsettings set org.cinnamon.settings-daemon.peripherals.touchpad natural-scroll false

echo "Notebook > On battery power > Turn off screen when inactive for 5 minutes"
gsettings set org.cinnamon.settings-daemon.plugins.power sleep-display-battery 300

echo "Notebook > On battery power > When lid is closed, do nothing"
gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-battery-action "nothing"

echo "Notebook > On A/C power > When lid is closed, do nothing"
gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-ac-action "nothing"

## NEMO

echo "Nemo > ignore per-folder view preferences"
gsettings set org.nemo.preferences ignore-view-metadata true

echo "Nemo > Show tooltips in icon and compact views"
gsettings set org.nemo.preferences tooltips-in-icon-view true

echo "Nemo > Detailed file type"
gsettings set org.nemo.preferences tooltips-show-file-type true

echo "Nemo > Plugins (Disable 'ChangeColorFolder' for performance on navigate folders)"
gsettings set org.nemo.plugins disabled-extensions '["EmblemPropertyPage+NemoPython", "PastebinitExtension+NemoPython", "NemoFilenameRepairer", "ChangeColorFolder+NemoPython"]'

## SHORTCUTS

echo "Change shortcut > Special key to move and resize windows: Super + Left click"
gsettings set org.cinnamon.desktop.wm.preferences mouse-button-modifier "<Super>"

echo -e "${ORANGE}Applying shortcut for run command: Super + r${NC}"
gsettings set org.cinnamon.desktop.keybindings.wm panel-run-dialog '["<Alt>F2", "<Super>r"]'

echo -e "${ORANGE}Applying shortcut for Media > Volume Down: ALT + SUPER + -${NC}"
gsettings set org.cinnamon.desktop.keybindings.media-keys volume-down '["XF86AudioLowerVolume", "<Alt><Super>KP_Subtract"]'

echo -e "${ORANGE}Applying shortcut for Media > Volume Up: ALT + SUPER + +${NC}"
gsettings set org.cinnamon.desktop.keybindings.media-keys volume-up '["XF86AudioRaiseVolume", "<Alt><Super>KP_Add"]'

echo -e "${ORANGE}Applying shortcut for Media > Play/Pause: ALT + SUPER + 5${NC}"
echo -e "${ORANGE}Applying shortcut for Media > Play/Pause: ALT + SUPER + i${NC}"
gsettings set org.cinnamon.desktop.keybindings.media-keys play '["XF86AudioPlay", "<Alt><Super>KP_5", "<Alt><Super>i"]'

echo -e "${ORANGE}Applying shortcut for Media > Next: ALT + SUPER + 6${NC}"
echo -e "${ORANGE}Applying shortcut for Media > Next: ALT + SUPER + o${NC}"
gsettings set org.cinnamon.desktop.keybindings.media-keys next '["XF86AudioNext", "<Alt><Super>KP_6", "<Alt><Super>o"]'

echo -e "${ORANGE}Applying shortcut for Media > Previous: ALT + SUPER + 4${NC}"
echo -e "${ORANGE}Applying shortcut for Media > Previous: ALT + SUPER + u${NC}"
gsettings set org.cinnamon.desktop.keybindings.media-keys previous '["XF86AudioPrev", "<Alt><Super>KP_4", "<Alt><Super>u"]'

echo -e "${ORANGE}Removing shortcut for workspace > <Control><Shift><Alt>Up|Down > Conflict with VS Code Duplicate Lines (Copy lines up|down)${NC}"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up '["<Super><Shift>Page_Up"]'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down '["<Super><Shift>Page_Down"]'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up '["<Super>Page_Up"]'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down '["<Super>Page_Down"]'


lastId=$(GetKeybindingLastId)

#su $SUDO_USER -c 'gsettings set org.cinnamon.desktop.keybindings custom-list '"'"'["custom0"]'"'"

# Check if custom-list is empty > create a dummy one
if [ -z "$(dconf read /org/cinnamon/desktop/keybindings/custom-list)" ]; then
    dconf write /org/cinnamon/desktop/keybindings/custom-list "['__dummy__']"
fi

#SHORTCUTS > SYSTEM MONITOR
echo -e "${ORANGE}Applying shortcut for System Monitor: CTRL + SHIFT + ESC${NC}"
newId=$(($lastId + 1))
newCustomId="custom${newId}"
if [ -z "$(KeybindingExists "<Primary><Shift>Escape")" ]; then
    setList=$(dconf read /org/cinnamon/desktop/keybindings/custom-list | sed -r "s/\[/['${newCustomId}', /g")
    dconf write /org/cinnamon/desktop/keybindings/custom-list "${setList}"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ name "System Monitor"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ command "gnome-system-monitor"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ binding '["<Primary><Shift>Escape"]'
fi

echo -e "${ORANGE}Applying shortcut for xkill: CTRL + ALT + X${NC}"
newId=$(($newId + 1))
newCustomId="custom${newId}"
if [ -z "$(KeybindingExists "<Primary><Super>x")" ]; then
    setList=$(dconf read /org/cinnamon/desktop/keybindings/custom-list | sed -r "s/\[/['${newCustomId}', /g")
    dconf write /org/cinnamon/desktop/keybindings/custom-list "${setList}"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ name "xkill"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ command "xkill"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ binding '["<Primary><Super>x"]'
fi

echo -e "${ORANGE}Applying shortcut for System Info: SUPER + Pause${NC}"
newId=$(($newId + 1))
newCustomId="custom${newId}"
if [ -z "$(KeybindingExists "<Super>Pause")" ]; then
    setList=$(dconf read /org/cinnamon/desktop/keybindings/custom-list | sed -r "s/\[/['${newCustomId}', /g")
    dconf write /org/cinnamon/desktop/keybindings/custom-list "${setList}"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ name "System Info"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ command "cinnamon-settings info"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/${newCustomId}/ binding '["<Super>Pause"]'
fi

echo -e "${ORANGE}Login settings > Enable numlock and dark theme${NC}"
loginSettingsFile="/etc/lightdm/slick-greeter.conf"
sudo crudini --set "${loginSettingsFile}" Greeter activate-numlock "true"
sudo crudini --set "${loginSettingsFile}" Greeter theme-name "Mint-Y-Dark"
sudo crudini --set "${loginSettingsFile}" Greeter icon-theme-name "Mint-Y-Yaru"

