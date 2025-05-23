#!/bin/bash
. "apps.sh" # Include apps.sh

# Associative array declaration with applications and categories
# declare -A apps=(
#     [smplayer, name]="SMPlayer media player"
#     [smplayer, category]="Media > Video & Movies"
#     [vlc, name]="VLC media player"
#     [vlc, category]="Media > Video & Movies"
#     [libreoffice, name]="LibreOffice suite"
#     [libreoffice, category]="Office & Productivity"
#     [onlyoffice, name]="OnlyOffice suite"
#     [onlyoffice, category]="Office & Productivity"
# )

# Temporary file to store selections
readonly GROUP_SELECTIONS_TMP_FILE="/tmp/group_selections.txt"

# Function to get all unique groups
function get_unique_groups() {
    local groups=()
    for key in "${!apps[@]}"; do
        if [[ $key =~ ^([a-z_]+)[[:space:]]*,[[:space:]]*category$ ]]; then
            category="${apps[$key]}"
            if [[ ! " ${groups[@]} " =~ " ${category} " ]]; then
                groups+=("$category")
            fi
        fi
    done
    printf "%s\n" "${groups[@]}" | sort -u
}

function create_dialog_options() {
    local categories="$1"
    local dialog_options=()
    local i=1
    while IFS= read -r category; do
        dialog_options+=("$i" "$category")
        ((i++))
    done <<< "$categories"
    printf '%s\n' "${dialog_options[@]}" # Index array can be returned like this, than, use readarray to convert it
}

# Function to show the main menu
function show_main_menu() {
    local categories
    categories=$(get_unique_groups)

    readarray -t dialog_options <<< "$(create_dialog_options "$categories")"

    # Adicionando a opção para listar os itens selecionados
    dialog_options+=("Apply" "\ZuUpdate & apply\Zn")

    export DIALOGRC="dialogrc"
    choice=$(dialog --backtitle "Select Options" \
        --colors \
        --cancel-label "Quit" \
        --menu "Select a group:" 0 0 0 \
        "${dialog_options[@]}" \
        2>&1 > /dev/tty)

    echo "Choice: $choice" # Debugging output

    case $choice in
        [0-9]*)
            local selected_group="${dialog_options[$((choice * 2 - 1))]}"
            show_apps_menu "$selected_group"
            ;;
        "Apply")
            apply_actions
            exit_script
            ;;
        *)
            exit_script
            ;;
    esac
}

function get_apps_in_group() {
    local group="$1"
    local -A apps_in_group=() # Associative array
    for key in "${!apps[@]}"; do
        if [[ "$key" =~ ^([a-z_]+)[[:space:]]*,[[:space:]]*category$ && "${apps[$key]}" == "$group" ]]; then
            local app_key="${key%,[[:space:]]*category}"
            apps_in_group["$app_key"]="${apps[$app_key, name]}"
        fi
    done
    declare -p apps_in_group # Associative array is not simple like indexed, so you must execute a eval after this, to convert it again
}

# Function to read selections
function read_group_selections() {
    local group="$1"
    if [ -f "$GROUP_SELECTIONS_TMP_FILE" ]; then
        grep "^$group|" "$GROUP_SELECTIONS_TMP_FILE" | cut -d '|' -f 2- | tr '|' ' '
    fi
}

# Function to read all selections
function read_selections() {
    cut -d '|' -f 2- "$GROUP_SELECTIONS_TMP_FILE" | tr '|' ' '
}

# Function to show apps menu
function show_apps_menu() {
    local group="$1"
    local apps_in_group
    apps_in_group=$(get_apps_in_group "$group")
    eval "$apps_in_group" # Convert it to associative array

    local selections
    read -ra selections <<< "$(read_group_selections "$group")"

    # Get ordered keys of associative array
    sorted_keys=($(printf '%s\n' "${!apps_in_group[@]}" | LC_ALL=C sort))

    # Loop associative array ordered
    local dialog_options=()
    for key in "${sorted_keys[@]}"; do
        # local app="${apps_in_group[$key]}"
        local app="$(queryAppMenu "$key")"
        local selected="off"
        for selected_app in "${selections[@]}"; do
            if [[ "$selected_app" == "$key" ]]; then
                selected="on"
                break
            fi
        done
        dialog_options+=("$key" "$app" "$selected")
    done

    export DIALOGRC="dialogrc"
    dialog --backtitle "Select Options" \
        --colors \
        --cancel-label "Back" \
        --separate-output \
        --output-separator '|' \
        --checklist "Select apps:" 0 0 0 \
        "${dialog_options[@]}" \
        2> /tmp/choice.txt

    choice=$(< /tmp/choice.txt)
    case $choice in
        *)
            if [ -f "$GROUP_SELECTIONS_TMP_FILE" ]; then        # Check if file exists
                sed -i "/^$group|/d" $GROUP_SELECTIONS_TMP_FILE # Cleaning $group
            fi
            if [[ -n "$choice" ]]; then
                local group_selection="$group|$choice|"
                echo "$group_selection" >> $GROUP_SELECTIONS_TMP_FILE
            fi
            show_main_menu
            ;;
    esac
}

# Function to exit the script
function exit_script() {
    rm -f "$GROUP_SELECTIONS_TMP_FILE"
    echo "Exiting..."
    exit 0
}

# Function to list selected items
function apply_actions() {
    clear

    echo -e "${YELLOW}Get and set custom parameters before starting (unattended mode, silent install)${NC}"
    # Force unattended mode (silent install), avoiding choices dialog. More explaining: <https://www.cyberciti.biz/faq/explain-debian_frontend-apt-get-variable-for-ubuntu-debian/>
    export NEEDRESTART_MODE=a
    export DEBIAN_FRONTEND=noninteractive
    ## Questions that you really, really need to see (or else). ##
    export DEBIAN_PRIORITY=critical

    local read_selections="$(read_selections)"
    for app_id in $read_selections; do
        action="${apps["$app_id, status"]}"
        if [ "$action" == "Install" ]; then
            echo -e "${GREEN}${apps["$app_id, name"]}${NC}"
            apps["${app_id}, extra_actions"]=$(${apps["$app_id, script"]} get-parameters)
        fi
        # echo "DEBUG > ${apps["$app_id, script"]}" "${action,,}" "$install_dont_update" "${apps["$app_id, extra_actions"]}"
    done

    echo # Add a linebreak
    echo -e "${RED}${BOLD}${UNDER}Script started! It's recommended to close every other application, like browsers, players, and wait until it is completed!${NC}"

    # Log everything and show on terminal
    log_file="${HOME}/appManager-log_$(date +%Y-%m-%d_%H-%M-%S).txt"
    exec > >(tee -i "$log_file") 2>&1

    #########################
    ##### UPDATE DISTRO #####
    #########################
    echo -e "${GREEN}Update/Refresh APT keys${NC}"
    sudo apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com
    sudo apt-get update -y -q 2>&1 | grep "NO_PUBKEY" | awk '{print $NF}' | while read key; do gpg --keyserver keyserver.ubuntu.com --recv-keys "$key" && gpg --export --armor "$key" | sudo apt-key add -; done

    #Update softwares (from repositories) [+intelligently handle the dependencies] [UPDATE ALSO DISTRO IF AVAILABLE]
    #sudo apt-get update #Already executed in "Update/Refresh APT keys"

    # UPDATE ALL EXPIRED KEYS
    echo -e "${GREEN}Updating expired keys${NC}"
    for K in $(APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key list | grep expired\|expirado | cut -d'/' -f2 | cut -d' ' -f1); do sudo apt-key adv --recv-keys --keyserver keys.gnupg.net "$K"; done

    echo -e "${GREEN}Distro upgrade${NC}"
    sudo apt-get update -y -q
    sudo apt-get -y -q -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" full-upgrade

    echo -e "${GREEN}Flatpak upgrade${NC}"
    flatpak update --noninteractive -y

    #AUTOSTART > CREATE CUSTOM FOLDER WITH DEFAULT USER PERMISSION
    mkdir -p "${HOME}/.config/autostart/"

    echo "Installing essential apps"
    ./apps/essentials-apps.sh

    # Apply selections
    local read_selections="$(read_selections)"
    for app_id in $read_selections; do
        action="${apps["$app_id, status"]}"
        install_dont_update=""
        if [ "$action" == "Install" ]; then
            install_dont_update="--dont-update"
        fi
        # echo "DEBUG > ${apps["$app_id, script"]}" "${action,,}" "$install_dont_update" "${apps["$app_id, extra_actions"]}"
        ${apps["$app_id, script"]} "${action,,}" "$install_dont_update" ${apps["$app_id, extra_actions"]} #Don't quote extra_actions!
    done

    echo -e "${GREEN}Fixing broken packages${NC}"
    sudo apt-get install -f -y -q

    echo -e "${GREEN}Autoremove apt-get cache downloads${NC}"
    echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | sudo tee /etc/apt/apt.conf.d/clean

    #CLEAN APP CACHE
    echo -e "${GREEN}Cleaning Up${NC}"
    sudo apt-get autoremove -y -q
    sudo apt-get autoclean -y -q
    sudo apt-get clean -y -q
    flatpak uninstall --unused -y

    #GENERATE KEYGEN FOR SSH
    sshFile="${HOME}/.ssh/id_rsa"
    if [ ! -f "$sshFile" ]; then
        echo -e "${GREEN}Creating keygen for SSH with empty password${NC}"
        ssh-keygen -t rsa -N "" -f "${sshFile}"
    fi

    echo
    echo -e "Time elapsed: $SECONDS seconds"
    echo
    echo -e "${RED}It's recommended to restart computer${NC}"
    read -r -p "Press any key to continue"
}

# Main loop
while true; do
    show_main_menu
done
