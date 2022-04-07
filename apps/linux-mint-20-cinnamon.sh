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

#Disabel autostart
#$3: filename
function DisableAutoStart(){
	cp "/etc/xdg/autostart/${1}.desktop" "${HOME}/.config/autostart/"
	StartupAppSetting "X-GNOME-Autostart-enabled" false "${HOME}/.config/autostart/${1}.desktop"
}

####################
##### CINNAMON #####
####################
echo -e "${Orange}Cinnamon Desktop${NC}"

############################
##### APPS > QUESTIONS #####
############################
#DROPBOX
while true; do
	echo -e "${ORANGE}Install${NC} Dropbox (nemo) (distro)? (Y/N): "
	read -p "" dropbox_install
	case $dropbox_install in
		[YyNn]* ) break;;
	esac
done

###############################
##### STARTUP > QUESTIONS #####
###############################
#redshift
while true; do
	echo -e "${GREEN}Enable startup${NC} redshift (blue light filter)? (Y/N): "
	read -p "" redshift_enable
	case $redshift_enable in
		[YyNn]* ) break;;
	esac
done

#bluetooth
while true; do
	echo -e "${RED}Disable startup${NC} bluetooth? (Y/N): "
	read -p "" bluetooth_disable
	case $bluetooth_disable in
		[YyNn]* ) break;;
	esac
done

#notification calendar
while true; do
	echo -e "${RED}Disable startup${NC} calendar/events notifications/alarms? (Y/N): "
	read -p "" evolution_notify_disable
	case $evolution_notify_disable in
		[YyNn]* ) break;;
	esac
done

#Trayicon for NVIDIA Prime
while true; do
	echo -e "${RED}Disable startup${NC} trayicon NVIDIA Prime? (Y/N): "
	read -p "" nvidia_trayicon_disable
	case $nvidia_trayicon_disable in
		[YyNn]* ) break;;
	esac
done

#Update
while true; do
	echo -e "${RED}Disable startup${NC} update manager? (Y/N): "
	read -p "" update_manager_disable
	case $update_manager_disable in
		[YyNn]* ) break;;
	esac
done

##########################
##### APPS > INSTALL #####
##########################
if [[ "$dropbox_install" == [yY] ]]; then
	sudo ./dropbox.sh
fi

#################################
##### STARTUP APPS > ENABLE #####
#################################
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
if [[ "$redshift_enable" == [yY] ]]; then
	REDSHIFT_DESKTOP_FILE="${HOME}/.config/autostart/redshift-gtk.desktop"
	if [ -f "$REDSHIFT_DESKTOP_FILE" ]; then
		StartupAppSetting "Hidden" false "${REDSHIFT_DESKTOP_FILE}"
		StartupAppSetting "X-GNOME-Autostart-enabled" true "${REDSHIFT_DESKTOP_FILE}"
		StartupAppSetting "Exec" "redshift-gtk -t 6000:4500" "${REDSHIFT_DESKTOP_FILE}"
	else 
		#CREATE FILE WITH USER PERMISSION. USING ECHO OR PRINTF DIRECTLY WILL CREATE WITH ROOT PERMISSION
		printf "${REDSHIFT_DESKTOP_CONTENT}" | tee -a "${REDSHIFT_DESKTOP_FILE}" > /dev/null
	fi
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
	DisableAutoStart "blueberry-obex-agent"
fi

#AUTOSTART > DISABLE > Alarm notifier for Evolution incoming events and appointments
if [[ "$evolution_notify_disable" == [yY] ]]; then
	DisableAutoStart "org.gnome.Evolution-alarm-notify"
fi

#AUTOSTART > DISABLE > NVIDIA PRIME
if [[ "$nvidia_trayicon_disable" == [yY] ]]; then
	DisableAutoStart "nvidia-prime"
fi

#AUTOSTART > DISABLE > UPDATE MANAGER
if [[ "$update_manager_disable" == [yY] ]]; then
	DisableAutoStart "mintupdate"
fi

#AUTOSTART > DISABLE > MINT WELCOME
DisableAutoStart "mintwelcome"

#AUTOSTART > DISABLE > BLUEBERRY
DisableAutoStart "blueberry-tray"

#AUTOSTART > DISABLE > ORCA SCREEN READER
DisableAutoStart "orca-autostart"

#AUTOSTART > DISABLE > CARIBOU (ON SCREEN KEYBOARD)
DisableAutoStart "caribou-autostart"

#AUTOSTART > DISABLE > RENAME FOLDERS BASED ON LANGUAGE
DisableAutoStart "user-dirs-update-gtk"

#AUTOSTART > DISABLE > AT SPI D-Bus Bus AT SPI stands for Assistive Technology Service Provider Interface: unwanted until you need the accessibility features
DisableAutoStart "at-spi-dbus-bus"

#AUTOSTART > DISABLE > VNC SERVER > DOESN'T HAVE ON MINT 19
#DisableAutoStart vino-server

#FIX PERMISSIONS OF COPIED FILES
#sudo chown --recursive $SUDO_USER:$SUDO_USER ~/.config/autostart/

#COMPRESSION LEVEL > MAXIMUM COMPRESSION FOR FILE-ROLLER (POSSIBLE VALUES: fast, normal, maximum)
gsettings set org.gnome.FileRoller.General compression-level "maximum"

#COMPRESSION LEVEL > MAXIMUM COMPRESSION FOR FILE-ROLLER (POSSIBLE VALUES: fast, normal, maximum)
gsettings set org.cinnamon.desktop.privacy remember-recent-files false

#CALENDAR WIDGET > INSERT DATE
# USE > ON THE SAME FILE WILL RETURN A BLANK FILE. HAVE TO CREATE A TEMPORARY FILE, THEN RENAME/MOVE IT
#jq '.["use-custom-format"]["value"] = true' ~/.cinnamon/configs/calendar@cinnamon.org/13.json > ~/.cinnamon/configs/calendar@cinnamon.org/13.json.$$ && mv ~/.cinnamon/configs/calendar@cinnamon.org/13.json.$$ ~/.cinnamon/configs/calendar@cinnamon.org/13.json
#jq '.["custom-format"]["value"] = "%d/%m/%Y %H:%M"' ~/.cinnamon/configs/calendar@cinnamon.org/13.json > ~/.cinnamon/configs/calendar@cinnamon.org/13.json.$$ && mv ~/.cinnamon/configs/calendar@cinnamon.org/13.json.$$ ~/.cinnamon/configs/calendar@cinnamon.org/13.json

#DESKTOP
	#DESKTOP > Show the Trash
	gsettings set org.nemo.desktop trash-icon-visible true

	#THEME > MINT-Y
	gsettings set org.cinnamon.desktop.interface gtk-theme "Mint-Y-Dark"
	gsettings set org.cinnamon.desktop.interface icon-theme "Mint-Y-Dark"
	gsettings set org.cinnamon.desktop.wm.preferences theme "Mint-Y"
	gsettings set org.cinnamon.theme name "Mint-Y-Dark"

#DISABLE LOCK ON MONITOR OFF
#gsettings set org.cinnamon.desktop.screensaver lock-enabled false

#DISABLE LOCK ON SUSPEND
#gsettings set org.cinnamon.settings-daemon.plugins.power lock-on-suspend false

#DISABLE LOCK ON IDLE TIME
#gsettings set org.cinnamon.desktop.session idle-delay 'uint32 0'

#NOTEBOOK
	#DISABLE REVERSE ROLLING
	gsettings set org.cinnamon.settings-daemon.peripherals.touchpad natural-scroll false

	#ON BATTERY POWER: TURN OFF SCREEN WHEN INACTIVE FOR 5 MINUTES
	gsettings set org.cinnamon.settings-daemon.plugins.power sleep-display-battery 300

	#ON BATTERY POWER: WHEN THE LID IS CLOSED > DO NOTHING
	gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-battery-action "nothing"

	#ON A/C POWER: WHEN THE LID IS CLOSED > DO NOTHING
	gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-ac-action "nothing"

#NEMO
	#NEMO > IGNORE PER-FOLDER VIEW PREFERENCES
	gsettings set org.nemo.preferences ignore-view-metadata true

	#NEMO > Show tooltips in icon and compact views
	gsettings set org.nemo.preferences tooltips-in-icon-view true

	#NEMO > Detailed file type
	gsettings set org.nemo.preferences tooltips-show-file-type true

	#NEMO > Plugins (Disable "ChangeColorFolder" for performance on navigate folders)
	gsettings set org.nemo.plugins disabled-extensions '["EmblemPropertyPage+NemoPython", "PastebinitExtension+NemoPython", "NemoFilenameRepairer", "ChangeColorFolder+NemoPython"]'

#SHORTCUTS
	#SHORTCUTS > RUN
	echo "Applying new shorctus"
	gsettings set org.cinnamon.desktop.keybindings.wm panel-run-dialog '["<Alt>F2", "<Super>r"]'

	#SHORTCUTS > SYSTEM MONITOR
	#su $SUDO_USER -c 'gsettings set org.cinnamon.desktop.keybindings custom-list '"'"'["custom0"]'"'"
	gsettings set org.cinnamon.desktop.keybindings custom-list '["custom0"]'
	gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ name "System Monitor"
	gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ command "gnome-system-monitor"
	gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ binding '["<Primary><Shift>Escape"]'

	#SHORTCUTS > xkill
	gsettings set org.cinnamon.desktop.keybindings custom-list '["custom1", "custom0"]'
	gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom1/ name "xkill"
	gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom1/ command "xkill"
	gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom1/ binding '["<Primary><Alt>x"]'

	#SHORTCUTS > System Info
	gsettings set org.cinnamon.desktop.keybindings custom-list '["custom2", "custom1", "custom0"]'
	gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom2/ name "System Info"
	gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom2/ command "cinnamon-settings info"
	gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom2/ binding '["<Super>Pause"]'

	#SHORTCUTS > Media > Volume Down
	gsettings set org.cinnamon.desktop.keybindings.media-keys volume-down '["XF86AudioLowerVolume", "<Alt><Super>KP_Subtract"]'

	#SHORTCUTS > Media > Volume Up
	gsettings set org.cinnamon.desktop.keybindings.media-keys volume-up '["XF86AudioRaiseVolume", "<Alt><Super>KP_Add"]'
	
	#SHORTCUTS > Media > Play/Pause
	gsettings set org.cinnamon.desktop.keybindings.media-keys play '["XF86AudioPlay", "<Alt><Super>KP_5", "<Alt><Super>i"]'
	
	#SHORTCUTS > Media > Next
	gsettings set org.cinnamon.desktop.keybindings.media-keys next '["XF86AudioNext", "<Alt><Super>KP_6", "<Alt><Super>o"]'
	
	#SHORTCUTS > Media > Previous
	gsettings set org.cinnamon.desktop.keybindings.media-keys previous '["XF86AudioPrev", "<Alt><Super>KP_4", "<Alt><Super>u"]'
