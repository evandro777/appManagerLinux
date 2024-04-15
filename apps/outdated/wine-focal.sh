#!/bin/bash

#COLORS
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${ORANGE}Installing Wine${NC}"

echo -e "${RED}WARNING: ${NC}"
echo -e "${ORANGE}THIS INSTALL IS FOR 'focal' VERSION > UBUNTU 20.04 OR LINUX MINT 20.x: ${NC}"
read -p "Press any key to continue"

#WINE > OFFICIAL
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
sudo apt-add-repository -y 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'

#Wine alternative repository (Official is breaking install using staging)

#https://www.linuxuprising.com/2019/09/how-to-install-wine-staging-development.html

#Install Wine-Staging from alternative repository "opensuse", because official has dependency problems
#"The following packages have unmet dependencies:
# winehq-staging : Depends: wine-staging (= 4.18~bionic)
#E: Unable to correct problems, you have held broken packages."

#wget -O- -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/Release.key | sudo apt-key add -
#echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04 ./" | sudo tee /etc/apt/sources.list.d/wine-obs.list

sudo apt-get update

sudo dpkg --add-architecture i386

sudo apt-get install -y -q --install-recommends winehq-staging

#WINE > winetricks
sudo apt-get install -y -q winetricks

#Manual Update to latest winetricks
#Download latest winetricks
wget "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" -O "/tmp/winetricks"

#Move downloaded winetricks, overwriting old one
sudo chmod --reference "/usr/bin/winetricks" "/tmp/winetricks"
sudo mv --force "/tmp/winetricks" "/usr/bin/"
# BELOW DOES NOT WORK WITH SUDO
#sudo cat /tmp/winetricks > /usr/bin/winetricks

#AFTER INSTALL RUN THIS PS.: Repeat the command in case of weird messages, it will check for installed ones and install new ones, if necessary.
sudo -u $SUDO_USER -H winetricks vcrun2010 corefonts droid lucida tahoma fontsmooth=rgb
#For some APPS LIKE PHOTOSHOP
#Adobe Type Manager (FOR SOME ADOBE PRODUCTS, LIKE PHOTOSHOP)
sudo -u $SUDO_USER -H winetricks atmlib
#GDI+, FONTSMOOTH (FIX GLITCH SOME ADOBE PRODUCTS, LIKE PHOTOSHOP)
sudo -u $SUDO_USER -H winetricks gdiplus
#heidsql > needed to connect to sqlserver
#winetricks mdac28 native_mdac

#REPLICATE THIS WINE PREFIX, IN CASE OF BUGS OR NEED MORE WINEPREFIX
#copy ~/.wine to ~/.wine-original
cp -ar ~/.wine ~/.wine-original
