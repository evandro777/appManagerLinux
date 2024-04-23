#!/bin/bash

. "apps.sh" # Include apps.sh

#TODO:
#Think about Create menu automatic, reading recursive directory (danger, executing all .sh)

#Example: $(ResultSelect installClementine)
#ResultSelect() {
#	local dynamicVariable="${1}"
#	echo $([ "${!dynamicVariable}" == "Y" ] && echo "Y" || echo "N")
#}

#Switch between Y | N
#$1: value (string)
#Example:
#	installClementine="N"
#	installClementine=$(SwitchYN $installClementine)
#	the result will be Y
SwitchYN() {
    local value="${1}"
    echo $([ "${value}" == "Y" ] && echo "N" || echo "Y")
}

#Color Y (Green) | N (White)
#$1: value (string)
#Example:
#	$(ColorYN $installClementine)
ColorYN() {
    local value="${1}"
    echo $([ "${value}" == "Y" ] && echo "${GREEN}Y${NC}" || echo "N")
}

MainMenu() {
    clear
    while true; do
        echo -e "${YELLOW}Choose${NC}: "
        echo -e "++++++++++++++++++++++++++"
        echo -e "| Media > Video & Movies |"
        echo -e "++++++++++++++++++++++++++"
        queryApp smplayer
        queryApp vlc
        queryApp gaupol
        queryApp stremio

        echo -e ""
        echo -e "+++++++++++++++++++++++++"
        echo -e "| Media > Audio & Music |"
        echo -e "+++++++++++++++++++++++++"
        queryApp spotify
        queryApp clementine
        queryApp strawberry
        queryApp rhythmbox

        echo -e ""
        echo -e "++++++++++++++++++"
        echo -e "| OS & Utilities |"
        echo -e "++++++++++++++++++"
        if [ "${recommendedDrivers}" ]; then
            echo -e "20: ${YELLOW}Install${NC} drivers > Official + Unofficial patches (${recommendedDrivers})?: $(ColorYN "$installDrivers")"
        fi
        if [[ $DESKTOP_SESSION == "cinnamon" ]]; then
            echo -e "21: ${RED}Setting${NC} Cinnamon: disable some autostart, install redshift, change theme, general adjustments, keyboard shortcuts?: $(ColorYN "$settingCinnamon")"
        fi
        queryApp variety
        queryApp seven_conky
        queryApp cpux
        queryApp gnome_settings_show_startup_apps
        queryApp xed_settings
        queryApp gnome_terminal_settings

        echo -e ""
        echo -e "+++++++++++++++++++++++++"
        echo -e "| Office & Productivity |"
        echo -e "+++++++++++++++++++++++++"
        queryApp libreoffice_ppa
        queryApp libreoffice
        queryApp onlyoffice
        queryApp thunderbird
        queryApp flameshot
        queryApp copyq
        queryApp dropbox

        echo -e ""
        echo -e "++++++++++++++++++++++"
        echo -e "| Security & Privacy |"
        echo -e "++++++++++++++++++++++"
        queryApp keepassxc
        queryApp flatseal

        echo -e ""
        echo -e "++++++++++++++++"
        echo -e "| File Sharing |"
        echo -e "++++++++++++++++"
        queryApp qbittorrent
        queryApp transmission

        echo -e ""
        echo -e "+++++++++++++++++++++++"
        echo -e "| Web Browsers & Chat |"
        echo -e "+++++++++++++++++++++++"
        queryApp chrome
        queryApp firefox_setting
        queryApp zoom
        queryApp discord

        echo -e ""
        echo -e "+++++++++++++++"
        echo -e "| Development |"
        echo -e "+++++++++++++++"
        queryApp ohmyzsh
        queryApp vscode
        queryApp dbeaver
        queryApp httpie
        queryApp meld
        queryApp docker
        queryApp insomnia

        echo -e ""
        echo -e "+++++++++"
        echo -e "| GAMES |"
        echo -e "+++++++++"
        queryApp steam
        queryApp lutris
        queryApp gamemode
        queryApp openrgb
        queryApp protonup_qt
        queryApp xpad_driver

        echo -e ""
        echo -e "++++++++++"
        echo -e "| Action |"
        echo -e "++++++++++"
        echo -e "A: ${GREEN}Upgrade & apply!${NC}"

        read -p "" menu_result
        case $menu_result in
            [Aa])
                applyActions="Y"
                break
                ;;

            #Media > Video & Movies
            "smplayer")
                apps[${menu_result}, action]=$(SwitchIU "${apps[${menu_result}, action]}")
                if [ "${apps[smplayer, action]}" == "Install" ]; then
                    clear
                    while true; do
                        echo -e "${YELLOW}Set${NC} SMPlayer default app to open videos? (Y/N): "
                        read -p "" setDefaultApp
                        case $setDefaultApp in
                            [YyNn]*) break ;;
                        esac
                    done
                    if [ "${setDefaultApp,,}" == "y" ]; then # ${setDefaultApp,,} > convert all content to lowercase
                        apps[smplayer, extra_actions]="--set-preferred-app"
                    else
                        apps[smplayer, extra_actions]=""
                    fi
                fi

                break
                ;;

            "vlc")
                apps[${menu_result}, action]=$(SwitchIU "${apps[${menu_result}, action]}")
                if [ "${apps[vlc, action]}" == "Install" ]; then
                    clear
                    while true; do
                        echo -e "${YELLOW}Set${NC} VLC default app to open videos? (Y/N): "
                        read -p "" setDefaultApp
                        case $setDefaultApp in
                            [YyNn]*) break ;;
                        esac
                    done
                    if [ "${setDefaultApp,,}" == "y" ]; then # ${setDefaultApp,,} > convert all content to lowercase
                        apps[vlc, extra_actions]="--set-preferred-app"
                    else
                        apps[vlc, extra_actions]=""
                    fi
                fi

                break
                ;;

            #OS & Utilities
            "20")
                installDrivers=$(SwitchYN "$installDrivers")
                break
                ;;

            "21")
                settingCinnamon=$(SwitchYN "$settingCinnamon")
                break
                ;;

            "27")
                settingXed=$(SwitchYN "$settingXed")
                break
                ;;

            *)
                # Auto verify and switch
                if [ -n "${apps[${menu_result}, action]}" ]; then
                    apps[${menu_result}, action]=$(SwitchIU "${apps[${menu_result}, action]}")
                fi
                MainMenu
                ;;
        esac
    done
    if [[ "$applyActions" != [yY] ]]; then
        MainMenu
    else
        apply_actions
    fi
}

apply_actions() {
    for app_key in "${!apps[@]}"; do
        if [[ $app_key =~ ^([a-z]+),[[:space:]]*status$ ]]; then
            app_id="${BASH_REMATCH[1]}"
            if [[ ${apps["$app_id, status"]} == ${apps["$app_id, action"]} ]]; then
                install_dont_update=""
                if [ "${apps["$app_id, action"]}" == "Install" ]; then
                    install_dont_update="--dont-update"
                fi
                ${apps["$app_id, script"]} "${apps["$app_id, action"],,}" "$install_dont_update" "${apps["$app_id, extra_actions"]}"
            fi
        fi
    done
    exit

    echo -e "${RED}${BOLD}${UNDER}Script started! It's recommended to close every other application, like browsers, players, and wait until it is completed!${NC}"

    # Log everything and show on terminal
    log_file="${HOME}/appManager-log_$(date +%Y-%m-%d_%H-%M-%S).txt"
    exec > >(tee -i "$log_file") 2>&1

    #########################
    ##### UPDATE DISTRO #####
    #########################
    echo -e "${GREEN}Update/Refresh APT keys${NC}"
    sudo apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com
    sudo apt-get update 2>&1 | grep "NO_PUBKEY" | awk '{print $NF}' | while read key; do gpg --keyserver keyserver.ubuntu.com --recv-keys "$key" && gpg --export --armor "$key" | sudo apt-key add -; done

    #Update softwares (from repositories) [+intelligently handle the dependencies] [UPDATE ALSO DISTRO IF AVAILABLE]
    #sudo apt-get update #Already executed in "Update/Refresh APT keys"

    # UPDATE ALL EXPIRED KEYS
    echo -e "${GREEN}Updating expired keys${NC}"
    for K in $(APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key list | grep expired\|expirado | cut -d'/' -f2 | cut -d' ' -f1); do sudo apt-key adv --recv-keys --keyserver keys.gnupg.net "$K"; done

    echo -e "${GREEN}Distro upgrade${NC}"
    apt update
    sudo apt-get dist-upgrade -y -u

    echo -e "${GREEN}Flatpak upgrade${NC}"
    flatpak update -y

    #AUTOSTART > CREATE CUSTOM FOLDER WITH DEFAULT USER PERMISSION
    mkdir -p "${HOME}/.config/autostart/"

    #UPDATE MANAGER > SET VISIBLE UPDATE LEVEL 1, 2, 3, 4, 5
    echo -e "${GREEN}Options for Update Manager${NC}"
    gsettings set com.linuxmint.updates show-size-column true
    gsettings set com.linuxmint.updates show-old-version-column true
    gsettings set com.linuxmint.updates show-origin-column true
    gsettings set com.linuxmint.updates autorefresh-hours 3

    ##################################
    ##### APPS > DEFAULT INSTALL #####
    ##################################
    ./apps/essentials-apps.sh

    #ALREADY REMOVED IN LINUX MINT 20+
    #if [[ "$uninstallVirtualboxguest" == [yY] ]]; then
    #	sudo apt-get purge --auto-remove -y virtualbox-guest*
    #fi

    ###############################
    ##### APPS > LOOP ACTIONS #####
    ###############################
    for app_key in "${!apps[@]}"; do
        if [[ $app_key =~ ^([a-z]+),[[:space:]]*status$ ]]; then
            app_id="${BASH_REMATCH[1]}"
            if [[ ${apps["$app_id, status"]} == ${apps["$app_id, action"]} ]]; then
                install_dont_update=""
                if [ "${apps["$app_id, action"]}" == "Install" ]; then
                    install_dont_update="--dont-update"
                fi
                ${apps["$app_id, script"]} "${apps["$app_id, action"],,}" "$install_dont_update" "${apps["$app_id, extra_actions"]}"
            fi
        fi
    done

    ############################
    ##### APPS > QUESTIONS #####
    ############################
    # Latest installs

    # Ask questions
    if [[ "$settingCinnamon" == [yY] ]]; then
        ./apps/mint-cinnamon-21.2.sh
    fi

    #OS & Utilities > NVIDIA > MOVED TO THE LAST INSTALLATION BECAUSE THERE ARE PATCHES APPLYED TO PREVIOUS INSTALLED FLATPAK
    if [[ "$installDrivers" == [yY] ]]; then
        sudo ubuntu-drivers autoinstall
        if [ "$(echo -e "${searchDrivers}" | grep 'vendor.*:' | grep 'NVIDIA')" ]; then
            ./apps/driver-nvidia-proprietary.sh
        fi
    fi

    echo -e "${GREEN}Fixing broken packages${NC}"
    sudo apt-get install -f

    echo -e "${GREEN}Autoremove apt-get cache downloads${NC}"
    echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | sudo tee /etc/apt/apt.conf.d/clean

    #CLEAN APP CACHE
    echo -e "${GREEN}Cleaning Up${NC}"
    sudo apt-get autoremove -y
    sudo apt-get autoclean -y
    sudo apt-get clean -y
    flatpak uninstall --unused -y

    #GENERATE KEYGEN FOR SSH
    sshFile="${HOME}/.ssh/id_rsa"
    if [ ! -f "$sshFile" ]; then
        echo -e "${GREEN}Creating keygen for SSH with empty password${NC}"
        ssh-keygen -t rsa -N "" -f "${sshFile}"
    fi

    echo -e "\nTime elapsed: $SECONDS seconds"
    echo -e "\nIt's recommended to restart computer"
    read -p "Press any key to continue"
}

MainMenu
