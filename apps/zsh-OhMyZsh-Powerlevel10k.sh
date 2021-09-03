#!/bin/bash
#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color
echo -e "${ORANGE}Installing ZSH With OhMyZsh PowerLevel10k${NC}"

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/essentials.sh"
. "../includes/root_restrict_but_sudo.sh"

CommandDependency "git" #Needed for installing oh-my-zsh and the powerlinetheme

#Update gnome terminal profile font for the MesloLGS font used by powerline
#$1: Profile hash
#Example: UpdateGnomeTerminalProfileFont "765e07a8-5a35-408a-b25c-630650a6c695"
function UpdateGnomeTerminalProfileFont(){
	local profileHash="${1}"
	local checkProfileExists=$(dconf read /org/gnome/terminal/legacy/profiles:/:"${profileHash}"/visible-name)
	
	if [ "${checkProfileExists}" ]; then
		dconf write /org/gnome/terminal/legacy/profiles:/:"${profileHash}"/use-system-font false
		dconf write /org/gnome/terminal/legacy/profiles:/:"${profileHash}"/font "'MesloLGS NF 11'"
	fi
}

#Fonts
sudo apt install -y fontconfig
wget --directory-prefix="${HOME}/.local/share/fonts/" https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
wget --directory-prefix="${HOME}/.local/share/fonts/" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
wget --directory-prefix="${HOME}/.local/share/fonts/" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
wget --directory-prefix="${HOME}/.local/share/fonts/" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
wget --directory-prefix="${HOME}/.local/share/fonts/" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
fc-cache -vf ~/.local/share/fonts/
wget --directory-prefix="${HOME}/.config/fontconfig/conf.d/" https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf


#Update gnome terminal profiles font for the MesloLGS font used by powerline
UpdateGnomeTerminalProfileFont "765e07a8-5a35-408a-b25c-630650a6c695"
UpdateGnomeTerminalProfileFont "5fb53c50-40ea-4836-9958-956ee13d6ed9"

#Install zsh
sudo apt install -y zsh zsh-autosuggestions zsh-syntax-highlighting

#SET AS DEFAULT SHELL
chsh -s /bin/zsh

#Install Oh-My-Zsh
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

#Install Oh-My-Zsh theme powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo 'Setting ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc'
sed -i 's/ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc

echo "IMPORTANT: Restart Zsh after updating Powerlevel10k. Do not use source ~/.zshrc"
echo "exit this shell and start a new one"
echo "Type \"p10k configure\" if the configuration wizard doesn't start automatically"

#If error like "command not found: ^M"
	#sudo apt install -y dos2unix
	#cd /home/evandro/.oh-my-zsh/themes/
	#find . -name "*.zsh-theme" | xargs dos2unix
	#find . -name "*.zsh" | xargs dos2unix
