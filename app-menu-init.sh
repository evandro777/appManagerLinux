#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/includes/essentials.sh"
. "$DIR/includes/root_restrict_but_sudo.sh"

#TODO:
#Think about Create menu automatic, reading recursive directory (danger, executing all .sh)

#Return a list of video mime types
#Example: GetVideoMimeTypes
function GetVideoMimeTypes(){
    echo $(cat /usr/share/applications/defaults.list | grep "video/\|x-content/video-" | sed 's/=.*$//g')
}

#Set preferred apps
#Example:
#	videoMimeTypes=$(cat /usr/share/applications/defaults.list | grep "video/\|x-content/video-" | sed 's/=.*celluloid_player.*$//g')
#	SetPreferredVideoApp $videoMimeTypes smplayer
#$1: array of mimeTypes
#$2: app name
#$3: file location
function  SetPreferredApp(){
    local mimeTypes="${1}"
    local appName="${2}"
    local fileLocation="${3}"
    #local fileLocation=$([ "${3}" ] && echo "${3}" || echo ${HOME}/.config/mimeapps.list)

    for mimeType in ${mimeTypes[@]}
    do
        crudini --set "${fileLocation}" "Default Applications" $mimeType "${appName}".desktop
        crudini --set "${fileLocation}" "Added Associations" $mimeType "${appName}".desktop
    done

    #Force remove white spaces " = ", happens when creating a new file, when editing a file that already doesn't have, it isn't needed
    TrimPropertys "${fileLocation}"
}

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
function SwitchYN(){
    local value="${1}"
    echo $([ "${value}" == "Y" ] && echo "N" || echo "Y")
}

#Color Y (Green) | N (White)
#$1: value (string)
#Example:
#	$(ColorYN $installClementine)
function ColorYN(){
    local value="${1}"
    echo $([ "${value}" == "Y" ] && echo "${GREEN}Y${NC}" || echo "N" )
}

#RESET PREFERED APPS
#Ubuntu = 14.04
#PREFERRED_APP_PATH=~/".local/share/applications/mimeapps.list"
#Ubuntu >= 16.04
PREFERRED_APP_PATH="${HOME}/.config/mimeapps.list"

#DRIVERS
searchDrivers="$(ubuntu-drivers devices)"
recommendedDrivers=$(echo "${searchDrivers}" | grep 'recommended' | cut -c12-)

#DEFAULT:
applyActions="N"

#Media > Video & Movies
installSmplayer="N"
installVLC="N"
defaultAppVLC="N"
installFFmpeg="N"
installGaupol="N"
installStremio="N"

#Media > Audio & Music
installSpotify="N"
installClementine="N"
installStrawberry="N"
uninstallRhythmbox="N"

#OS & Utilities
installDrivers="N"
settingCinnamon="N"
installWine="N"
installVariety="N"
installSevenConky="N"
installCpux="N"
settingShowAllStartupApps="N"
settingXed="N"
settingGnomeTerminal="N"
settingSamba="N"

#Office & Productivity
uninstallLibreOffice="N"
installLibreOfficeFlatpak="N"
installOnlyOffice="N"
uninstallThunderbird="N"
installFlameshot="N"
installCopyQ="N"
installDropbox="N"

#Security & Privacy
installKeePassXC="N"
installFlatseal="N"

#File Sharing
installQBittorrent="N"
uninstallTransmission="N"

#Web Browsers & Chat
installChrome="N"
settingFirefox="N"
installZoom="N"
installDiscord="N"

#Development
installZshOhMyZshPowerlevel10k="N"
installVsCode="N"
installHeidiSql="N"
installDbeaver="N"
installHttpie="N"
installMeld="N"
installDocker="N"
installInsomnia="N"

#Games
installSteam="N"
installLutris="N"
installGamepadXpadDriver="N"

MainMenu() {
    clear
    while true; do
        echo -e "${ORANGE}Choose${NC}: "
        echo -e "++++++++++++++++++++++++++"
        echo -e "| Media > Video & Movies |"
        echo -e "++++++++++++++++++++++++++"
        echo -e "11: ${ORANGE}Install${NC} SMPlayer (official PPA)?: $(ColorYN $installSmplayer)"
        echo -e "12: ${ORANGE}Install${NC} VLC (distro repository)?: $(ColorYN $installVLC) [default app: $defaultAppVLC]"
        echo -e "13: ${ORANGE}Install${NC} FFmpeg (distro repository)?: $(ColorYN $installFFmpeg)"
        echo -e "14: ${ORANGE}Install${NC} Gaupol (distro repository)?: $(ColorYN $installGaupol)"
        echo -e "15: ${ORANGE}Install${NC} Stremio (official Flatpak)?: $(ColorYN $installStremio)"

        echo -e ""
        echo -e "+++++++++++++++++++++++++"
        echo -e "| Media > Audio & Music |"
        echo -e "+++++++++++++++++++++++++"
        echo -e "16: ${ORANGE}Install${NC} Spotify (official PPA)?: $(ColorYN $installSpotify)"
        echo -e "17: ${ORANGE}Install${NC} Clementine Music Player (official PPA)?: $(ColorYN $installClementine)"
        echo -e "18: ${ORANGE}Install${NC} Strawberry Music Player (official PPA)?: $(ColorYN $installStrawberry)"
        echo -e "19: ${RED}Uninstall${NC} Rhythmbox?: $(ColorYN $uninstallRhythmbox)"

        echo -e ""
        echo -e "++++++++++++++++++"
        echo -e "| OS & Utilities |"
        echo -e "++++++++++++++++++"
        if [ "${recommendedDrivers}" ]; then
            echo -e "20: ${ORANGE}Install${NC} drivers > Official + Unofficial patches (${recommendedDrivers})?: $(ColorYN $installDrivers)"
        fi
        if [[ $DESKTOP_SESSION == "cinnamon" ]]; then
            echo -e "21: ${RED}Setting${NC} Cinnamon: disable some autostart, install redshift, change theme, general adjustments, keyboard shortcuts?: $(ColorYN $settingCinnamon)"
        fi
        echo -e "22: ${ORANGE}Install${NC} Wine [Ubuntu: 20.04 - focal] (official PPA)?: $(ColorYN $installWine)"
        echo -e "23: ${ORANGE}Install${NC} Variety Wallpaper (official PPA)?: $(ColorYN $installVariety)"
        echo -e "24: ${ORANGE}Install${NC} seven-conky with autostart (official git repository)?: $(ColorYN $installSevenConky)"
        echo -e "25: ${ORANGE}Install${NC} cpu-x (distro repository)?: $(ColorYN $installCpux)"

        echo -e "26: ${RED}Setting${NC} Show all hidden startup applications?: $(ColorYN $settingShowAllStartupApps)"
        echo -e "27: ${RED}Setting${NC} Xed > tweaking?: $(ColorYN $settingXed)"
        echo -e "28: ${RED}Setting${NC} Gnome terminal > tweaking?: $(ColorYN $settingGnomeTerminal)"
        echo -e "29: ${RED}Setting${NC} Samba (network share) > less restrictions (caution). Tip: Share public folder and create symlinks: $(ColorYN $settingSamba)"

        echo -e ""
        echo -e "+++++++++++++++++++++++++"
        echo -e "| Office & Productivity |"
        echo -e "+++++++++++++++++++++++++"
        echo -e "30: ${RED}Uninstall${NC} Libreoffice?: $(ColorYN $uninstalllLibreOffice)"
        echo -e "31: ${ORANGE}Install${NC} Libreoffice (official Flatpak)?: $(ColorYN $installLibreOfficeFlatpak)"
        echo -e "32: ${ORANGE}Install${NC} OnlyOffice (official Flatpak)?: $(ColorYN $installOnlyOffice)"
        echo -e "33: ${RED}Uninstall${NC} Thunderbird e-mail?: $(ColorYN $uninstallThunderbird)"
        echo -e "34: ${ORANGE}Install${NC} Flameshot (official PPA)?: $(ColorYN $installFlameshot)"
        echo -e "35: ${ORANGE}Install${NC} CopyQ [Clipboard Manager] (official PPA)?: $(ColorYN $installCopyQ)"
        echo -e "36: ${ORANGE}Install${NC} Dropbox (distro)?: $(ColorYN $installDropbox)"

        echo -e ""
        echo -e "++++++++++++++++++++++"
        echo -e "| Security & Privacy |"
        echo -e "++++++++++++++++++++++"
        echo -e "40: ${ORANGE}Install${NC} KeePassXC (official Flatpak)?: $(ColorYN $installKeePassXC)"
        echo -e "41: ${ORANGE}Install${NC} Flatseal (Manage Flatpak permissions) - Official Flatpak?: $(ColorYN $installFlatseal)"

        echo -e ""
        echo -e "++++++++++++++++"
        echo -e "| File Sharing |"
        echo -e "++++++++++++++++"
        echo -e "50: ${ORANGE}Install${NC} QBittorrent (official PPA)?: $(ColorYN $installQBittorrent)"
        echo -e "51: ${RED}Uninstall${NC} Transmission torrent?: $(ColorYN $uninstallTransmission)"

        echo -e ""
        echo -e "+++++++++++++++++++++++"
        echo -e "| Web Browsers & Chat |"
        echo -e "+++++++++++++++++++++++"
        echo -e "60: ${ORANGE}Install${NC} Chrome (official PPA)?: $(ColorYN $installChrome)"
        echo -e "61: ${RED}Setting${NC} Firefox > tweaking?: $(ColorYN $settingFirefox)"
        echo -e "62: ${ORANGE}Install${NC} Zoom (official deb download/update)?: $(ColorYN $installZoom)"
        echo -e "63: ${ORANGE}Install${NC} Discord (Unofficial Flatpak)?: $(ColorYN $installDiscord)"

        echo -e ""
        echo -e "+++++++++++++++"
        echo -e "| Development |"
        echo -e "+++++++++++++++"
        echo -e "71: ${ORANGE}Install${NC} ZSH With OhMyZsh PowerLevel10k (distro repository)?: $(ColorYN $installZshOhMyZshPowerlevel10k)"
        echo -e "72: ${ORANGE}Install${NC} VS Code (official PPA)?: $(ColorYN $installVsCode)"
        echo -e "73: ${ORANGE}Install${NC} HeidiSQL [Requires Wine] (Custom download)?: $(ColorYN $installHeidiSql)"
        echo -e "74: ${ORANGE}Install${NC} DBeaver (official PPA)?: $(ColorYN $installDbeaver)"
        echo -e "75: ${ORANGE}Install${NC} HTTPie (RESTful calls) (distro repository)?: $(ColorYN $installHttpie)"
        echo -e "76: ${ORANGE}Install${NC} Meld [Compare files] (distro repository)?: $(ColorYN $installMeld)"
        echo -e "77: ${ORANGE}Install${NC} Docker (official PPA)?: $(ColorYN $installDocker)"
        echo -e "78: ${ORANGE}Install${NC} Insomnia (official PPA)?: $(ColorYN $installInsomnia)"

        echo -e ""
        echo -e "+++++++++"
        echo -e "| GAMES |"
        echo -e "+++++++++"
        echo -e "80: ${ORANGE}Install${NC} Steam (distro repository)?: $(ColorYN $installSteam)"
        echo -e "81: ${ORANGE}Install${NC} Lutris (official Flatpak)?: $(ColorYN $installLutris)"
        echo -e "82: ${ORANGE}Install${NC} More gamepad xpad drivers (Unofficial Git)?: $(ColorYN $installGamepadXpadDriver)"

        echo -e ""
        echo -e "++++++++++"
        echo -e "| Action |"
        echo -e "++++++++++"
        echo -e "A: ${GREEN}Upgrade & apply!${NC}"


        read -p "" menu_result
        case $menu_result in
            [Aa])
                applyActions="Y"
                break;;

            #Media > Video & Movies
            "11")
                installSmplayer=$(SwitchYN $installSmplayer)
                break;;

            "12")
                installVLC=$(SwitchYN $installVLC)
                clear
                while true; do
                    echo -e "${ORANGE}Set${NC} VLC default app to open videos? (Y/N): "
                    read -p "" defaultAppVLC
                    case $defaultAppVLC in
                        [YyNn]* ) break;;
                    esac
                done

                break;;

            "13")
                installFFmpeg=$(SwitchYN $installFFmpeg)
                break;;

            "14")
                installGaupol=$(SwitchYN $installGaupol)
                break;;
                
            "15")
                installStremio=$(SwitchYN $installStremio)
                break;;

            #Media > Audio & Music
            "16")
                installSpotify=$(SwitchYN $installSpotify)
                break;;

            "17")
                installClementine=$(SwitchYN $installClementine)
                break;;

            "18")
                installStrawberry=$(SwitchYN $installStrawberry)
                break;;

            "19")
                uninstallRhythmbox=$(SwitchYN $uninstallRhythmbox)
                break;;

            #OS & Utilities
            "20")
                installDrivers=$(SwitchYN $installDrivers)
                break;;

            "21")
                settingCinnamon=$(SwitchYN $settingCinnamon)
                break;;

            "22")
                installWine=$(SwitchYN $installWine)
                break;;

            "23")
                installVariety=$(SwitchYN $installVariety)
                break;;

            "24")
                installSevenConky=$(SwitchYN $installSevenConky)
                break;;

            "25")
                installCpux=$(SwitchYN $installCpux)
                break;;

            "26")
                settingShowAllStartupApps=$(SwitchYN $settingShowAllStartupApps)
                break;;

            "27")
                settingXed=$(SwitchYN $settingXed)
                break;;

            "28")
                settingGnomeTerminal=$(SwitchYN $settingGnomeTerminal)
                break;;

            "29")
                settingSamba=$(SwitchYN $settingSamba)
                break;;

            # Office & Productivity
            "30")
                uninstallLibreOffice=$(SwitchYN $uninstallLibreOffice)
                break;;

            "31")
                installLibreOfficeFlatpak=$(SwitchYN $installLibreOfficeFlatpak)
                break;;

            "32")
                installOnlyOffice=$(SwitchYN $installOnlyOffice)
                break;;

            "33")
                uninstallThunderbird=$(SwitchYN $uninstallThunderbird)
                break;;

            "34")
                installFlameshot=$(SwitchYN $installFlameshot)
                break;;

            "35")
                installCopyQ=$(SwitchYN $installCopyQ)
                break;;

            "36")
                installDropbox=$(SwitchYN $installDropbox)
                break;;

            #Security & Privacy
            "40")
                installKeePassXC=$(SwitchYN $installKeePassXC)
                break;;

            "41")
                installFlatseal=$(SwitchYN $installFlatseal)
                break;;

            #File Sharing
            "50")
                installQBittorrent=$(SwitchYN $installQBittorrent)
                break;;

            "51")
                uninstallTransmission=$(SwitchYN $uninstallTransmission)
                break;;

            #Web Browsers & Chat
            "60")
                installChrome=$(SwitchYN $installChrome)
                break;;

            "61")
                settingFirefox=$(SwitchYN $settingFirefox)
                break;;

            "62")
                installZoom=$(SwitchYN $installZoom)
                break;;

            "63")
                installDiscord=$(SwitchYN $installDiscord)
                break;;

            #Development
            "71")
                installZshOhMyZshPowerlevel10k=$(SwitchYN $installZshOhMyZshPowerlevel10k)
                break;;

            "72")
                installVsCode=$(SwitchYN $installVsCode)
                break;;

            "73")
                installHeidiSql=$(SwitchYN $installHeidiSql)
                break;;

            "74")
                installDbeaver=$(SwitchYN $installDbeaver)
                break;;

            "75")
                installHttpie=$(SwitchYN $installHttpie)
                break;;

            "76")
                installMeld=$(SwitchYN $installMeld)
                break;;

            "77")
                installDocker=$(SwitchYN $installDocker)
                break;;

            "78")
                installInsomnia=$(SwitchYN $installInsomnia)
                break;;

            #Games
            "80")
                installSteam=$(SwitchYN $installSteam)
                break;;

            "81")
                installLutris=$(SwitchYN $installLutris)
                break;;

            "82")
                installGamepadXpadDriver=$(SwitchYN $installGamepadXpadDriver)
                break;;

            *) MainMenu
        esac
    done
    if [[ "$applyActions" != [yY] ]]; then
        MainMenu
    else
        Actions
    fi
}

Actions() {
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
    for K in $(APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key list | grep expired\|expirado | cut -d'/' -f2 | cut -d' ' -f1); do sudo apt-key adv --recv-keys --keyserver keys.gnupg.net $K; done

    echo -e "${GREEN}Distro upgrade${NC}"
    sudo apt-get dist-upgrade -y -u

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
    ./apps/essentials.sh

    #ALREADY REMOVED IN LINUX MINT 20+
    #if [[ "$uninstallVirtualboxguest" == [yY] ]]; then
    #	sudo apt-get purge --auto-remove -y virtualbox-guest*
    #fi

    ############################
    ##### APPS > QUESTIONS #####
    ############################
    if [[ "$installVLC" == [yY] ]]; then
        ./apps/vlc.sh
        if [[ "$defaultAppVLC" == [yY] ]]; then
            #cat /usr/share/applications/defaults.list | grep "video/\|x-content/video-" | sed 's/=io.github.celluloid_player.*$/=vlc.desktop/g' >> "${PREFERRED_APP_PATH}"
            SetPreferredApp "$(GetVideoMimeTypes)" "vlc" "${PREFERRED_APP_PATH}"
        fi
    fi

    if [[ "$installSmplayer" == [yY] ]]; then
        ./apps/smplayer-ppa-official.sh
        if [[ "$smplayer_default" == [yY] ]]; then
            #cat /usr/share/applications/defaults.list | grep "video/\|x-content/video-" | sed 's/=io.github.celluloid_player.*$/=smplayer.desktop/g' >> "${PREFERRED_APP_PATH}"
            SetPreferredApp "$(GetVideoMimeTypes)" "smplayer" "${PREFERRED_APP_PATH}"
        fi
    fi

    if [[ "$installFFmpeg" == [yY] ]]; then
        ./apps/ffmpeg.sh
    fi

    if [[ "$installGaupol" == [yY] ]]; then
        ./apps/gaupol.sh
    fi

    if [[ "$installStremio" == [yY] ]]; then
        ./apps/stremio-flatpak-official.sh
    fi

    #Media > Audio & Music
    if [[ "$installSpotify" == [yY] ]]; then
        ./apps/spotify-ppa-official.sh
    fi

    if [[ "$installStrawberry" == [yY] ]]; then
        ./apps/strawberry-ppa-official.sh
    fi

    if [[ "$installClementine" == [yY] ]]; then
        ./apps/clementine.sh
    fi

    if [[ "$uninstallRhythmbox" == [yY] ]]; then
        #USING * IN THE END DOES NOT WORK WITH sudo apt purge, MUST use apt-get purge
        sudo apt-get purge --auto-remove -y rhythmbox*
    fi

    #OS & Utilities
    #WARNING: MOCKED UBUNTU VERSION
    if [[ "$installWine" == [yY] ]]; then
        ./apps/wine-focal.sh
    fi

    if [[ "$installVariety" == [yY] ]]; then
        ./apps/variety-ppa-official.sh
    fi

    if [[ "$installCpux" == [yY] ]]; then
        ./apps/cpu-x.sh
    fi

    if [[ "$settingShowAllStartupApps" == [yY] ]]; then
        sudo sed -i 's/NoDisplay=true/NoDisplay=false/g' /etc/xdg/autostart/*.desktop
    fi

    if [[ "$settingXed" == [yY] ]]; then
        ./apps/xed-config.sh
    fi

    if [[ "$settingGnomeTerminal" == [yY] ]]; then
        ./apps/gnome-terminal-config.sh
    fi

    if [[ "$settingSamba" == [yY] ]]; then
        ./apps/samba.sh
    fi

    #Office & Productivity
    if [[ "$uninstallLibreOffice" == [yY] ]]; then
        sudo apt-get remove --purge -y "libreoffice*"
    fi

    if [[ "$installLibreOfficeFlatpak" == [yY] ]]; then
        ./apps/libreoffice-flatpak-official.sh
    fi

    if [[ "$installOnlyOffice" == [yY] ]]; then
        ./apps/onlyoffice-flatpak-official.sh
    fi

    if [[ "$uninstallThunderbird" == [yY] ]]; then
        #USING * IN THE END DOES NOT WORK WITH sudo apt purge, MUST use apt-get purge
        sudo apt-get purge --auto-remove -y thunderbird*
    fi

    if [[ "$installFlameshot" == [yY] ]]; then
        ./apps/flameshot.sh
    fi

    if [[ "$installCopyQ" == [yY] ]]; then
        ./apps/copyq-ppa-official.sh
    fi

    if [[ "$installDropbox" == [yY] ]]; then
        ./apps/dropbox.sh
    fi

    #Security & Privacy
    if [[ "$installKeePassXC" == [yY] ]]; then
        ./apps/keepassxc-flatpak-official.sh
    fi

    if [[ "$installFlatseal" == [yY] ]]; then
        ./apps/Flatseal-flatpak-official.sh
    fi

    #File Sharing
    if [[ "$installQBittorrent" == [yY] ]]; then
        ./apps/qbittorrent-ppa-official.sh
    fi

    if [[ "$uninstallTransmission" == [yY] ]]; then
        sudo apt-get purge --auto-remove -y transmission-gtk
    fi

    #Web Browsers & Chat
    if [[ "$installChrome" == [yY] ]]; then
        ./apps/chrome-ppa-official.sh
    fi

    if [[ "$settingFirefox" == [yY] ]]; then
        ./apps/firefox-config.sh
    fi

    if [[ "$installZoom" == [yY] ]]; then
        ./apps/zoom-deb-official.sh
    fi

    if [[ "$installDiscord" == [yY] ]]; then
        ./apps/discord-flatpak-unofficial.sh
    fi

    #Development
    if [[ "$installVsCode" == [yY] ]]; then
        ./apps/vscode-ppa-official.sh
    fi

    if [[ "$installHeidiSql" == [yY] ]]; then
        ./apps/heidisql-bin-download.sh
    fi

    if [[ "$installDbeaver" == [yY] ]]; then
        ./apps/dbeaver-ppa-official.sh
    fi

    if [[ "$installHttpie" == [yY] ]]; then
        ./apps/httpie.sh
    fi

    if [[ "$installMeld" == [yY] ]]; then
        ./apps/meld.sh
    fi

    if [[ "$installDocker" == [yY] ]]; then
        ./apps/docker-ppa-official.sh
    fi

    if [[ "$installInsomnia" == [yY] ]]; then
        ./apps/insomnia-ppa-official.sh
    fi

    #Games
    if [[ "$installSteam" == [yY] ]]; then
        ./apps/steam.sh
    fi

    if [[ "$installLutris" == [yY] ]]; then
        ./apps/lutris-flatpak-official.sh
    fi

    if [[ "$installGamepadXpadDriver" == [yY] ]]; then
        ./apps/gamepad-xpad-driver-unofficial-git.sh
    fi

    # Latest installs

    # Ask questions
    if [[ "$installSevenConky" == [yY] ]]; then
        ./apps/seven-conky.sh
    fi

    # Ask questions
    if [[ "$settingCinnamon" == [yY] ]]; then
        ./apps/mint-cinnamon-21.2.sh
    fi

    # Ask for password
    if [[ "$installZshOhMyZshPowerlevel10k" == [yY] ]]; then
        ./apps/zsh-OhMyZsh-Powerlevel10k.sh
    fi

    #OS & Utilities > NVIDIA > MOVED TO THE LAST INSTALLATION BECAUSE THERE ARE PATCHES APPLYED TO PREVIOUS INSTALLED FLATPACK
    if [[ "$installDrivers" == [yY] ]]; then
        sudo ubuntu-drivers autoinstall
        if [ "$(echo -e "${searchDrivers}" | grep 'vendor.*:' | grep 'NVIDIA')" ]; then
            ./apps/nvidia-driver-proprietary.sh
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
