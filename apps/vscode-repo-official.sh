#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="*Custom extensions* VS Code (+font ligatures +custom configs)[official repository]"
#stable: code, unstable: code-insiders
readonly APPLICATION_ID="code"
readonly APPLICATION_KEYRING=/etc/apt/keyrings/packages.microsoft.gpg
readonly APPLICATION_SOURCE_LIST=/etc/apt/sources.list.d/vscode.list
readonly APPLICATION_CUSTOM_JSON_CONFIG=$(
    cat << EOF
{
    "editor.renderWhitespace": "all",
    "editor.minimap.enabled": false,
    "editor.fontFamily": "'Fira Code', 'Droid Sans Mono', 'monospace', 'monospace', 'Droid Sans Fallback'",
    "terminal.integrated.fontFamily": "'MesloLGS NF'",
    "window.titleBarStyle": "custom",
    "editor.fontLigatures": true,
    "editor.lineHeight": 24,
    "editor.fontSize": 16,
    "editor.stickyScroll.enabled": true,
    "cSpell.language": "en,pt,pt_BR",
    "cSpell.enableFiletypes": [
        "shellscript"
    ],
    "[markdown]": {
        "editor.defaultFormatter": "DavidAnson.vscode-markdownlint",
        "editor.formatOnSave": true
    },
    "markdown.extension.list.indentationSize": "inherit",
    "markdownlint.config": {
        "default": true,
        "MD013": false,
        "MD007": {
            "indent": 4
        }
    },
    "[shellscript]": {
        "editor.formatOnSave": true
    },
    "shellcheck.customArgs": [
        "-x"
    ],
    "shellformat.flag": "--case-indent --space-redirects --indent 4 --binary-next-line"
}
EOF
)

readonly APPLICATION_CUSTOM_JSON_KEYBINDING=$(
    cat << EOF
{
    "key": "ctrl+shift+alt+d",
    "command": "editor.action.copyLinesDownAction",
    "when": "editorTextFocus"
}
EOF
)

function perform_install() {
    # VS Code repository official
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg "$APPLICATION_KEYRING"
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by='$APPLICATION_KEYRING'] https://packages.microsoft.com/repos/code stable main" > '$APPLICATION_SOURCE_LIST
    rm -f packages.microsoft.gpg

    package_update
    package_install apt-transport-https "$APPLICATION_ID"

    # FIRA CODE (FONT WITH LIGATURES)
    sudo apt-get install -y -q fonts-firacode

    # Settings:
    echo -e "Applying settings to VS Code${NC}"

    user_configs_path="${HOME}/.config/Code/User/"
    mkdir -p "${user_configs_path}"

    user_configs_settings="${user_configs_path}settings.json"

    # Check if the destination file exists or is empty
    if [ ! -s "$user_configs_settings" ]; then
        # The file doesn't exist or is empty, so use the original JSON directly
        echo "{}" > "$user_configs_settings"
    fi

    # The file exists, so use `jq` to add or update only the necessary keys
    jq --argjson orig "$APPLICATION_CUSTOM_JSON_CONFIG" '. + $orig' "$user_configs_settings" > "${HOME}/.config/Code/User/settings_temp.json"
    mv "${HOME}/.config/Code/User/settings_temp.json" "$user_configs_settings"

    # Plugins
    # highlight .env
    code --install-extension mikestead.dotenv

    # PHPDoc
    #code --install-extension neilbrayfield.php-docblocker

    # PHP INTELEPHENSE
    #code --install-extension bmewburn.vscode-intelephense-client

    # Code Runner
    #code --install-extension formulahendry.code-runner

    # Markdown (.md) lint
    code --install-extension davidanson.vscode-markdownlint

    # Markdown (.md) all-in-one
    code --install-extension yzhang.markdown-all-in-one

    # bash shellcheck
    code --install-extension timonwong.shellcheck

    # Code Spell Checker
    code --install-extension streetsidesoftware.code-spell-checker

    # Code Spell Checker - Brazilian Portuguese
    # code --install-extension streetsidesoftware.code-spell-checker-portuguese-brazilian

    # bash ide
    # code --install-extension mads-hartmann.bash-ide-vscode

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

    echo -e "Applying Keybindings to VS Code${NC}"

    user_keybindings="${user_configs_path}keybindings.json"

    # Check if the destination file exists or is empty
    if [ ! -s "$user_keybindings" ]; then
        # The file doesn't exist or is empty, so use the original JSON directly
        # echo "// Place your key bindings in this file to overwrite the defaults" > "$user_keybindings" # Do not use this with `jq`, common json is not allowed commentary
        echo "[]" >> "$user_keybindings"
    fi

    # Check if the key already exists in the array
    if jq --arg key "ctrl+shift+alt+d" 'map(select(.key == $key)) | length' "$user_keybindings" | grep -qv '^0$'; then
        echo "The key binding already exists in $user_keybindings."
    else
        # The file exists, so use `jq` to add or update only the necessary keys
        jq --argjson orig "$APPLICATION_CUSTOM_JSON_KEYBINDING" '. += [$orig]' "$user_keybindings" > "${HOME}/.config/Code/User/keybindings_temp.json"
        mv "${HOME}/.config/Code/User/keybindings_temp.json" "$user_keybindings"
    fi

}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"""
    sudo rm "$APPLICATION_SOURCE_LIST"
    sudo rm "$APPLICATION_KEYRING"
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
