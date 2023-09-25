#!/bin/bash

sudo apt-get install -y fortune-mod
sudo apt-get install -y fortunes-br
sudo apt-get install -y cowsay

function update_bash {
	echo '' >> $1
	echo 'if [ -x /usr/games/cowsay -a -x /usr/games/fortune ]; then' >> $1
	echo '	fortune | cowsay' >> $1
	echo 'fi' >> $1

	source $1
}

FILE="$HOME"/.zshrc
if test -f "$FILE"; then
	update_bash "$FILE"
fi

FILE="$HOME"/.bashrc
if test -f "$FILE"; then
	update_bash "$FILE"
fi
