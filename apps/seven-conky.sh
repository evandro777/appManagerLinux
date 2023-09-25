#!/bin/bash

installLocation="${HOME}/.conky/seven-conky/" autoStart="y" bash <(curl -s https://raw.githubusercontent.com/evandro777/seven-conky/main/install.sh)

sudo apt-get install -y fonts-font-awesome

sudo chmod +s /usr/sbin/hddtemp
