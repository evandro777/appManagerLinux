#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/essentials.sh"
. "../includes/root_restrict_but_sudo.sh"

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color
echo -e "${ORANGE}Installing VSCode${NC}"

#VSCODE repository official
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt update

#FIRA CODE (FONT WITH LIGATURES)
sudo apt install -y fonts-firacode

#VS CODE
sudo apt install -y apt-transport-https
# Stable
sudo apt install -y code
# Bleeding edge
#sudo apt-get install code-insiders

#Settings:
printf '{
	"editor.renderWhitespace": "all",
	"editor.minimap.enabled": false,
	"editor.fontFamily": "'"'"'Fira Code'"'"', '"'"'Droid Sans Mono'"'"', '"'"'monospace'"'"', monospace, '"'"'Droid Sans Fallback'"'"'",
	"editor.fontLigatures": true,
	"editor.lineHeight": 24,
	"editor.fontSize": 16,
	"php.suggest.basic": false
}' | tee -a ~/.config/Code/User/settings.json > /dev/null

#Plugins
#highlight .htaccess
#sudo -u $SUDO_USER -H code --install-extension mrmlnc.vscode-apache

#highlight .env
#sudo -u $SUDO_USER -H code --install-extension mikestead.dotenv

#Highlight TODO:, FIXME:
#sudo -u $SUDO_USER -H code --install-extension wayou.vscode-todo-highlight

#PHPDoc
#sudo -u $SUDO_USER -H code --install-extension neilbrayfield.php-docblocker

#PHP INTELEPHENSE
#sudo -u $SUDO_USER -H code --install-extension bmewburn.vscode-intelephense-client

#VUE
#sudo -u $SUDO_USER -H code --install-extension octref.vetur

#Code Runner
#sudo -u $SUDO_USER -H code --install-extension formulahendry.code-runner

#Class import checker (if not using an import)
#sudo -u $SUDO_USER -H code --install-extension marabesi.php-import-checker

#Markdown (.md) lint
#sudo -u $SUDO_USER -H code --install-extension davidanson.vscode-markdownlint

#Markdown table formater (beautify)
#sudo -u $SUDO_USER -H code --install-extension shuworks.vscode-table-formatter

#Local history
#sudo -u $SUDO_USER -H code --install-extension xyz.local-history

#Settings:
printf '// Place your key bindings in this file to overwrite the defaults
[
	{
		"key": "ctrl+shift+d",
		"command": "editor.action.addSelectionToNextFindMatch",
		"when": "editorFocus"
	},
	{
		"key": "ctrl+d",
		"command": "-editor.action.addSelectionToNextFindMatch",
		"when": "editorFocus"
	},
	{
		"key": "ctrl+d",
		"command": "editor.action.copyLinesDownAction",
		"when": "editorTextFocus && !editorReadonly"
	},
	{
		"key": "ctrl+shift+alt+down",
		"command": "-editor.action.copyLinesDownAction",
		"when": "editorTextFocus && !editorReadonly"
	}
]' | tee -a ~/.config/Code/User/keybindings.json > /dev/null
