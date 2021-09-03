# appManagerLinux

[![made-with-bash](https://img.shields.io/badge/Bash-1f425f?logo=gnubash)](https://www.gnu.org/software/bash/)
[![made-for-linux-mint](https://img.shields.io/badge/LinuxMint-1f425f?logo=linuxmint)](https://linuxmint.com/)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-orange)](https://opensource.org/licenses/GPL-3.0)

Terminal Application / System Manager for Linux Mint Cinnamon

Script i created for easy installing applications through terminal, some using official thirdparty PPA to get most recent versions

The main idea is to use it on fresh install, eliminating a lot of manual effort

The script is tested on Linux Mint 20.2 Cinnamon. Some routines are only executed if is using Cinnamon, but the script should run fine on Mate as well.

## Disclaimer

**WARNING:** I do **NOT** take responsibility for what may happen to your system! Run scripts at your own risk!

## Option 1: Clone repository
	git clone https://github.com/evandro777/appManagerLinux.git
	cd appManagerLinux

## Option 2: Download and extract
	wget https://github.com/evandro777/appManagerLinux/archive/refs/heads/main.zip
	unzip -q -o "main.zip"
	cd appManagerLinux-main

## Run the script
	./app-menu-init.sh
