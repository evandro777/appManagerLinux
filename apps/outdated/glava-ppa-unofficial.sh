#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing GLava - Unofficial repository (linuxuprising/apps)${NC}"

sudo add-apt-repository ppa:linuxuprising/apps
sudo apt-get update
sudo apt-get install glava

glava --copy-config


echo '
Display monitors and resolutions
	xrandr | grep " connected"
	OR
	xrandr | grep "*" | sed "s/|/ /" | awk '{print $1}'

Config is located at:
	~/.config/glava/rc.glsl

	Better performance, disable it on fullscreen applications, set:
		setfullscreencheck true

force-mod options: bars, radial, graph, wave or circle

Configure screen resolution and monitor to display
	--request="setgeometry 1920 0 1360 768"

Display fullscreen on first monitor
	glava --desktop --force-mod=radial --request="setgeometry 0 0 1920 1080"

Display fullscreen on second monitor
	glava --desktop --force-mod=radial --request="setgeometry 1920 0 1360 768"'
