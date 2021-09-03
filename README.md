# appManagerLinux
Terminal Application / System Manager for Linux Mint Cinnamon

Script i created for easy installing applications through terminal, some using official thirdparty PPA to get most recent versions

The main idea is to use it on fresh install, eliminating a lot of manual effort

The script is tested on Linux Mint 20.2 Cinnamon. Some routines are only executed if is using Cinnamon, but the script should run fine on Mate as well.

## Option 1: Clone repository
	git clone https://github.com/evandro777/appManagerLinux.git
	cd appManagerLinux

## Option 2: Download and extract
	wget https://github.com/evandro777/appManagerLinux/archive/refs/heads/main.zip
	unzip -q -o "main.zip"
	cd appManagerLinux-main

## Run the script
	./app-menu-init.sh
