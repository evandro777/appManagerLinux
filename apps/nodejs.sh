#!/bin/bash
#######################
##### ROOT ACCESS #####
#######################
#if [ $EUID != "0" ]; then
	#echo "Must be run as root!" 1>&2
	##exit 1
	#if [ -t 1 ]; then
	  #exec sudo -- "$0" "$@"
	#else
	  #exec gksudo -- "$0" "$@"
	#fi
#fi

#INSTALL NODE FROM OFFICIAL REPOSITORY
#curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
#sudo apt install -y nodejs

#USING SNAP
#sudo apt install -y snapd
#sudo snap install node --classic

#DO NOT USE ROOT!
#USING NVM
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

# UPDATE ZSH
FILE="$HOME"/.zshrc
if test -f "$FILE"; then
	echo '' >> $FILE
	echo 'export NVM_DIR="$HOME/.nvm"' >> $FILE
	echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> $FILE
	echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> $FILE
	
	source $FILE
fi

#Install latest version of node
nvm install --lts

# SET DEFAULT SHELL LATEST NODE VERSION 
#nvm alias default node