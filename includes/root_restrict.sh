#!/bin/bash
#######################
##### ROOT ACCESS #####
#######################
if [ $EUID == "0" ]; then
	echo "Must not be run as root!" 1>&2
	exit 1
fi

if [[ $SUDO_USER ]]; then
	#AVOID USING EVAL: USER_HOME=$(eval echo ~${SUDO_USER})
	USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
	REAL_USER="$SUDO_USER"
else
	USER_HOME=$HOME
	REAL_USER="$@"
fi

# Translate Real Username to Real User ID
RUSER_UID=$(id -u ${REAL_USER})

# drop privileges back to non-root user if we got here with sudo. Ex.: depriv touch a
function Depriv(){
	if [[ $SUDO_USER ]]; then
		sudo -u "$SUDO_USER" -H -- "$@"
	else
		"$@"
	fi
}

function RunInUserSession(){
	local _display_id=":$(find /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"
	local _username=$(who | grep "\(${_display_id}\)" | awk '{print $1}')
	local _user_id=$(id -u "$_username")
	local _environment=("DISPLAY=$_display_id" "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$_user_id/bus")
	sudo -Hu "$_username" env "${_environment[@]}" "$@"
}
