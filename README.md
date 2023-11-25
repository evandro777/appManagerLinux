# appManagerLinux

[![made-with-bash](https://img.shields.io/badge/Bash-1f425f?logo=gnubash)](https://www.gnu.org/software/bash/)
[![made-for-linux-mint](https://img.shields.io/badge/LinuxMint-1f425f?logo=linuxmint)](https://linuxmint.com/)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-orange)](https://opensource.org/licenses/GPL-3.0)

Terminal Application / System Manager for Linux Mint Cinnamon

I created this script for easy installing applications through terminal, some using official PPA, third party PPA, Flatpak to get most recent versions

The main idea is to use it on a fresh install, eliminating a lot of manual effort. Using this on a running system might clean some configurations already applied, so use it with caution.

The script is tested on Linux Mint 21.2 Cinnamon. Some routines are only executed if is using Cinnamon, but the script should run fine on Mate as well.

## Disclaimer

**WARNING:** I do **NOT** take responsibility for what may happen to your system! Run scripts at your own risk!

## Option 1: Clone repository

```bash
git clone --depth=1 https://github.com/evandro777/appManagerLinux.git
cd appManagerLinux
```

## Option 2: Download and extract

```bash
wget https://github.com/evandro777/appManagerLinux/archive/refs/heads/main.zip
unzip -q -o "main.zip"
cd appManagerLinux-main
```

## Run the script

`./app-menu-init.sh`
