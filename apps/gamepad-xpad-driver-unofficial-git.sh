#!/bin/bash

#COLORS
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${ORANGE}Installing & updating Xpad Linux Kernel Driver - Unofficial Git${NC}"
echo -e "Driver for the Xbox, Xbox 360, Xbox 360 Wireless, Xbox One Controllers and similars like 8bitdo and others"
echo -e "More information at: https://github.com/paroj/xpad"
echo -e "Alternative to use 8bitdo with xinput without installing: https://gist.github.com/ammuench/0dcf14faf4e3b000020992612a2711e2"
echo -e "To identify plugged usb gamepad and peripherals, execute `lsusb`"

echo -e "Clearing already installed driver"
rm -rf /usr/src/xpad-0.4

echo -e "Getting updated version"
sudo git clone --depth=1 https://github.com/paroj/xpad.git /usr/src/xpad-0.4

echo -e "Removing alterady installed driver"
sudo dkms remove -m xpad -v 0.4 --all

echo -e "Installing new driver"
sudo dkms install -m xpad -v 0.4

