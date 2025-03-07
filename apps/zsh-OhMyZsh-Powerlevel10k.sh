#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="ZSH [official PPA] With OhMyZsh [official Git] and PowerLevel10k [official Git]"
readonly APPLICATION_ID="zsh"
readonly APPLICATION_PACKAGES="zsh zsh-autosuggestions zsh-syntax-highlighting"

function perform_install() {
    command_dependency "git" # Needed for installing oh-my-zsh and the Powerline Theme

    package_install $APPLICATION_PACKAGES

    # SET AS DEFAULT SHELL
    # chsh --shell /bin/zsh # this form always asks password
    sudo chsh --shell /bin/zsh "$USER"

    # Oh-My-Zsh
    echo -e "${YELLOW}Installing Oh-My-Zsh${NC}"
    #sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    wget --no-verbose "https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh" -O - | zsh

    # Powerlevel10k
    echo -e "${YELLOW}Installing Powerlevel10k${NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

    echo 'Setting ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc'
    sed -i 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc

    echo 'Adding plugins git, colored-man-pages and command-not-found'
    sed -i 's/^plugins=(.*$/plugins=(git colored-man-pages command-not-found)/g' ~/.zshrc

    # Copy file if not exists to create a default theme
    cp --no-clobber .p10k.zsh "${HOME}/.p10k.zsh" && echo "Default theme applied to OhMyZsh PowerLevel10k"

    # Check if the line exists at the beginning of the file
    if ! grep -q "source \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\"" "${HOME}/.zshrc"; then
        # Read the current content of the file
        contents=$(cat "${HOME}/.zshrc")
        # Add the lines at the beginning of the file
        {
            echo '# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.'
            echo '# Initialization code that may require console input (password prompts, [y/n]'
            echo '# confirmations, etc.) must go above this block; everything else may go below.'
            echo 'if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then'
            echo '  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"'
            echo 'fi'
            echo ''
            echo "$contents" # Add the original content after the new lines
        } > "${HOME}/.zshrc"
    fi

    # Check if the line exists in the file
    if ! grep -q "source ~/.p10k.zsh" "${HOME}/.zshrc"; then
        # Append the line to the end of the file
        echo '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.' >> "${HOME}/.zshrc"
        echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> "${HOME}/.zshrc"
    fi

    echo -e "${YELLOW}IMPORTANT: Restart Zsh after updating Powerlevel10k. Do not use source ~/.zshrc${NC}"
    echo -e "exit this shell and start a new one or restart computer"
    echo -e "A default customized theme will be used"
    echo -e "${GREEN}Type \"p10k configure\" to use configuration wizard and customize theme${NC}"

    echo -e "${YELLOW}Windows terminal users${NC}"
    echo -e 'If error like "command not found: ^M"'
    echo -e "execute:"
    echo -e "sudo apt-get install -y -q dos2unix"
    echo -e "cd /home/my_user/.oh-my-zsh/themes/"
    echo -e "find . -name "*.zsh-theme" | xargs dos2unix"
    echo -e "find . -name "*.zsh" | xargs dos2unix"
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
