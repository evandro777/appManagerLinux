#!/bin/bash

readonly APPLICATION_NAME="Game optimizations"
readonly PIPEWIRE_CONF_FILE="$HOME/.config/pipewire/pipewire.conf.d/99-improve-game-sound.conf"
readonly PIPEWIRE_CONF_CONTENT=$(
    cat << 'EOF'
context.properties = {
    default.clock.allowed-rates = [ 44100 48000 ]
}
EOF
)

function perform_install() {
    echo -e "${YELLOW}Applying game optimizations${NC}"

    echo -e "${YELLOW}Increasing vm.max_map_count${NC}"
    echo 'Having the default vm.max_map_count size limit of 65530 maps can be too little for some games. Increasing to 2147483642'
    printf "vm.max_map_count = 2147483642" | sudo tee /etc/sysctl.d/80-gamecompatibility.conf > /dev/null

    sudo sysctl --system

    audio_optimization
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
}

function perform_check() {
    package_is_installed=2
    echo $package_is_installed
}

function audio_optimization(){
    echo "Applying sound (pipewire) optimization: include allowed rate 44100. Improve speed with no resampling for 44100"
    mkdir -p "$(dirname "$PIPEWIRE_CONF_CONTENT")"
    echo "$PIPEWIRE_CONF_FILE" > "$PIPEWIRE_CONF_CONTENT"

    echo -e "${YELLOW}Add $USER to group audio${NC}"
    echo "Useful to audio having more priority, avoiding sound crackling/popping"
    sudo usermod -a -G audio $USER

    echo "Restarting audio"
    systemctl --user daemon-reexec
    systemctl --user restart pipewire.service pipewire-pulse.service wireplumber.service
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
