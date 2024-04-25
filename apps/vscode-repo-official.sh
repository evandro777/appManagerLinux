#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="VS Code (+font ligatures +custom configs +prompt extensions)[official repository]"
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
    "editor.stickyScroll.enabled": true
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

    # Access the associative array passed as a parameter
    local -n params=$1

    # Extensions
    if [ "${params[base\-programming],,}" == "y" ]; then
        echo "Installing extension for colorizing indentation: oderwat.indent-rainbow"
        code --install-extension oderwat.indent-rainbow

        echo "Installing extension for consistent coding styles: EditorConfig.EditorConfig"
        code --install-extension EditorConfig.EditorConfig

        # echo "Installing extension for highlight .env: mikestead.dotenv"
        # code --install-extension mikestead.dotenv
    fi

    if [ "${params[editor],,}" == "y" ]; then
        echo "Installing extension for markdown features (.md): yzhang.markdown-all-in-one"
        code --install-extension yzhang.markdown-all-in-one
        update_json_prop_file '.["markdown.extension.list.indentationSize"] = "inherit"' "${user_configs_settings}"

        echo "Installing extension for markdown lint (.md): davidanson.vscode-markdownlint"
        code --install-extension davidanson.vscode-markdownlint
        update_json_prop_file '.["[markdown]"].editor.defaultFormatter = "DavidAnson.vscode-markdownlint" |
            .["[markdown]"].editor.formatOnSave = true |
            .["markdownlint.config"].default = true |
            .["markdownlint.config"].MD013 = false |
            .["markdownlint.config"].MD007 = {"indent": 4}' "${user_configs_settings}"

        echo "Installing extension for spell checking: streetsidesoftware.code-spell-checker"
        code --install-extension streetsidesoftware.code-spell-checker
        # Check if "shellscript" is already present in cSpell.enableFiletypes
        if ! jq '.["cSpell.enableFiletypes"] | index("shellscript")' "$user_configs_settings" | grep -q "null"; then
            # If "shellscript" is not present, add it to the array
            update_json_prop_file '.["cSpell.enableFiletypes"] += ["shellscript"]' "${user_configs_settings}"
        fi

        # Markdown table formatter (beautify)
        # sudo -u $SUDO_USER -H code --install-extension shuworks.vscode-table-formatter
    fi

    if [ "${params[editor\-spellcheck\-ptbr],,}" == "y" ]; then
        echo "Installing extension for spell checking (pt-br): streetsidesoftware.code-spell-checker-portuguese-brazilian"
        code --install-extension streetsidesoftware.code-spell-checker-portuguese-brazilian
        update_json_prop_file '.["cSpell.language"] = "en,pt,pt_BR"' "${user_configs_settings}"
    fi

    if [ "${params[shell\-script],,}" == "y" ]; then
        echo "Installing extension for shell script lint (.sh): timonwong.shellcheck"
        code --install-extension timonwong.shellcheck
        update_json_prop_file '.["shellcheck.customArgs"] = ["-x"]' "${user_configs_settings}"

        # Formats shell scripts, Dockerfiles, gitignore, dotenv, properties, hosts, .bats
        echo "Installing extension for formating shell script, gitignore, doenvt, properties, hosts, bats: foxundermoon.shell-format"
        code --install-extension foxundermoon.shell-format
        update_json_prop_file '.["[shellscript]"].editor.formatOnSave = true |
            .["shellformat.flag"] = "--case-indent --space-redirects --indent 4 --binary-next-line"' "${user_configs_settings}"

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
    fi

    # PHP INTELEPHENSE
    #code --install-extension bmewburn.vscode-intelephense-client

    # PHPDoc
    #code --install-extension neilbrayfield.php-docblocker

    # Code Runner
    #code --install-extension formulahendry.code-runner

    # bash ide
    # code --install-extension mads-hartmann.bash-ide-vscode

    # Local history
    # sudo -u $SUDO_USER -H code --install-extension xyz.local-history

    # Class import checker (if not using an import)
    # sudo -u $SUDO_USER -H code --install-extension marabesi.php-import-checker

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

function get_parameters() {
    # Don't use echo before read, it's not going to work to set into a variable "app-menu-init.sh"
    read -rp $'Install editor (markdown, spellcheck) extensions [y | n (default)]?: \n' editor
    read -rp $'Install editor spellcheck "português brasileiro" extension [y | n (default)]?: \n' editor_spellcheck_ptbr
    read -rp $'Install base programming extensions (.env highlight, color indentation) [y | n (default)]: \n' base_programming
    read -rp $'Install shell script extensions [y | n (default)]: \n' shell_script

    echo "--editor=$editor --editor-spellcheck-ptbr=$editor_spellcheck_ptbr --shell-script=$shell_script --base-programming=$base_programming"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
