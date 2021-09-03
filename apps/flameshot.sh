#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color
echo -e "${ORANGE}Installing Flameshot${NC}"

apt update
sudo apt install -y flameshot

if $DESKTOP_SESSION = "cinnamon"; then
	#SHORTCUTS > Super + Print Screen
	gsettings set org.cinnamon.desktop.keybindings custom-list '["custom3", "custom2", "custom1", "custom0"]'
	gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom3/ name "Flameshot"
	gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom3/ command "flameshot gui"
	gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom3/ binding '["<Super>Print"]'
fi
