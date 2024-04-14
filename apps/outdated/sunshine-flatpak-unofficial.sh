#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing sunshine - Unofficial Flatpak${NC}"

echo "Flatpak version of sunshine may have some problems, like launching Steam, hardware decoding. If that happens, try getting the Appimage version manually"

echo "Allow Sunshine Virtual Input (Required)"
sudo chown $USER /dev/uinput && echo 'KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/85-sunshine-input.rules

echo "Sunshine uses a self-signed certificate. The web browser will report it as not secure, but it is safe."

echo "Allow Sunshine to start apps and games. (Optional)"
sudo flatpak override --talk-name=org.freedesktop.Flatpak dev.lizardbyte.app.Sunshine

#echo "KMS Grab (Optional)"
#sudo -i PULSE_SERVER=unix:$(pactl info | awk '/Server String/{print$3}') flatpak run --socket=wayland dev.lizardbyte.app.Sunshine

flatpak install --user -y flathub dev.lizardbyte.app.Sunshine
