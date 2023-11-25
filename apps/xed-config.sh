#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Configure XED${NC}"

#DRACULA THEME
echo "Installing dracula theme for XED"
#This code below is nice, but it doesn't overwrite the file if already exists
#sudo wget --directory-prefix="/usr/share/gtksourceview-3.0/styles/" https://raw.githubusercontent.com/dracula/gedit/master/dracula.xml

wget https://raw.githubusercontent.com/dracula/gedit/master/dracula.xml
sudo cp dracula.xml /usr/share/gtksourceview-3.0/styles/
sudo mv dracula.xml /usr/share/gtksourceview-4/styles/

#XED
echo "Options for XED"
gsettings set org.x.editor.preferences.editor highlight-current-line true
gsettings set org.x.editor.preferences.editor display-line-numbers true
gsettings set org.x.editor.preferences.editor bracket-matching true
#gsettings set org.x.editor.preferences.editor insert-spaces false
gsettings set org.x.editor.preferences.editor auto-indent true
gsettings set org.x.editor.preferences.editor draw-whitespace true
gsettings set org.x.editor.preferences.editor draw-whitespace-leading true
gsettings set org.x.editor.preferences.editor draw-whitespace-trailing true
gsettings set org.x.editor.preferences.editor prefer-dark-theme true
gsettings set org.x.editor.preferences.editor scheme "dracula"
gsettings set org.x.editor.plugins active-plugins '["sort", "modelines", "filebrowser", "wordcompletion", "textsize", "taglist", "docinfo", "time", "spell"]'
