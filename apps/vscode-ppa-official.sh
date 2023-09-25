#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/essentials.sh"
. "../includes/root_restrict_but_sudo.sh"

# COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing VSCode${NC}"

# VSCODE repository official
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

sudo apt-get update

# FIRA CODE (FONT WITH LIGATURES)
sudo apt-get install -y fonts-firacode

# VS CODE
sudo apt-get install -y apt-transport-https
# Stable
sudo apt-get install -y code
# Bleeding edge
# sudo apt-get install code-insiders

# Settings:
printf '{
    "editor.renderWhitespace": "all",
    "editor.minimap.enabled": false,
    "editor.fontFamily": "'"'"'Fira Code'"'"', '"'"'Droid Sans Mono'"'"', '"'"'monospace'"'"', monospace, '"'"'Droid Sans Fallback'"'"'",
    "terminal.integrated.fontFamily": "'"'"'MesloLGS NF'"'"',
    "window.titleBarStyle": "custom",
    "editor.fontLigatures": true,
    "editor.lineHeight": 24,
    "editor.fontSize": 16,
    "php.suggest.basic": false,
    "cSpell.language": "en,pt,pt_BR",
    "[markdown]": {
        "editor.defaultFormatter": "DavidAnson.vscode-markdownlint",
        "editor.formatOnSave": true
    },
    "markdown.extension.list.indentationSize": "inherit"
}' | tee -a ~/.config/Code/User/settings.json >/dev/null

# Plugins
# highlight .env
code --install-extension mikestead.dotenv

# PHPDoc
code --install-extension neilbrayfield.php-docblocker

# PHP INTELEPHENSE
code --install-extension bmewburn.vscode-intelephense-client

# Code Runner
code --install-extension formulahendry.code-runner

# Markdown (.md) lint
code --install-extension davidanson.vscode-markdownlint

# Formats shell scripts, Dockerfiles, gitignore, dotenv, properties, hosts, .bats
code --install-extension foxundermoon.shell-format
# To disable formatOnSave for shellscript open user settings (CTRL + SHIFT + P => Type user settings):
# "[shellscript]": {
# 	"editor.formatOnSave": false
# },
# "shellformat.effectLanguages": [
# 	"dockerfile",
# 	"dotenv",
# 	"hosts",
# 	"jvmoptions",
# 	"ignore",
# 	"gitignore",
# 	"properties",
# 	"spring-boot-properties",
# 	"azcli",
# 	"bats"
# ]

# Indentation more readable by colorizing
code --install-extension oderwat.indent-rainbow

# Markdown table formater (beautify)
# sudo -u $SUDO_USER -H code --install-extension shuworks.vscode-table-formatter

# Local history
# sudo -u $SUDO_USER -H code --install-extension xyz.local-history

# Class import checker (if not using an import)
# sudo -u $SUDO_USER -H code --install-extension marabesi.php-import-checker

# Highlight TODO:, FIXME:
# sudo -u $SUDO_USER -H code --install-extension wayou.vscode-todo-highlight

# highlight .htaccess
# sudo -u $SUDO_USER -H code --install-extension mrmlnc.vscode-apache

# VUE
# sudo -u $SUDO_USER -H code --install-extension octref.vetur

# Settings:
printf '// Place your key bindings in this file to overwrite the defaults
[
    {
        "key": "ctrl+shift+alt+d",
        "command": "editor.action.copyLinesDownAction",
        "when": "editorTextFocus"
    }
]' | tee -a ~/.config/Code/User/keybindings.json >/dev/null
