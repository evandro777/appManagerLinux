#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="ZSH [official PPA] With OhMyZsh [official Git] and PowerLevel10k [official Git]"
readonly APPLICATION_ID="zsh"
readonly APPLICATION_PACKAGES="zsh zsh-autosuggestions zsh-syntax-highlighting"

function perform_install() {
    command_dependency "git" # Needed for installing oh-my-zsh and the powerlinetheme

    package_install "$APPLICATION_PACKAGES"

    # SET AS DEFAULT SHELL
    chsh -s /bin/zsh

    # Oh-My-Zsh
    echo -e "${YELLOW}Installing Oh-My-Zsh${NC}"
    #sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    wget --no-verbose https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

    # Powerlevel10k
    echo -e "${YELLOW}Installing Powerlevel10k${NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

    echo 'Setting ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc'
    sed -i 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc

    echo 'Adding plugins git, colored-man-pages and command-not-found'
    sed -i 's/^plugins=(.*$/plugins=(git colored-man-pages command-not-found)/g' ~/.zshrc

    # Copy file if not exists to create a default theme
    cp --no-clobber .p10k.zsh "${HOME}/.p10k.zsh" && echo "Default theme applied to OhMyZsh PowerLevel10k"

    echo "IMPORTANT: Restart Zsh after updating Powerlevel10k. Do not use source ~/.zshrc"
    echo "exit this shell and start a new one"
    echo "Type \"p10k configure\" to use configuration wizard"

    echo 'If error like "command not found: ^M"'
    echo "execute:"
    echo "sudo apt-get install -y dos2unix"
    echo "cd /home/evandro/.oh-my-zsh/themes/"
    echo "find . -name "*.zsh-theme" | xargs dos2unix"
    echo "find . -name "*.zsh" | xargs dos2unix"
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_PACKAGES"
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
