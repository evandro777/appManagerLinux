#!/bin/bash

readonly APPLICATION_NAME="Firefox > Settings > Dark theme, +security +performance +custom"

function get_firefox_config_file() {
    firefox_config_file=$(find "${HOME}"/.mozilla/firefox/*/prefs.js 2> /dev/null)
    if [[ "$firefox_config_file" == "" ]]; then
        echo "Firefox > prefs.js not found. Starting firefox for creating and exit"
        firefox &
        pid=$! && sleep 7 && wmctrl -ic $(wmctrl -lp | awk -vpid="$pid" '$3==pid {print $1; exit}') && sleep 3 # Wait for close
        firefox_config_file=$(find "${HOME}"/.mozilla/firefox/*/prefs.js)
    fi
    if [[ "$firefox_config_file" == "" ]]; then
        echo "${RED}Firefox > an error ocurred, couldn't find prefs.js${NC}"
        exit 1
    fi
    echo "$firefox_config_file"
}

function validate_firefox_running() {
    process="firefox"
    while pidof "$process" > /dev/null; do
        while true; do
            echo -e "${ORANGE}Firefox${NC} is running! Close manually and press any key to continue: "
            read -p "" firefoxClose
            case $firefoxClose in
                *) break ;;
            esac
        done
        #while true; do
        #	echo -e "${ORANGE}Firefox${NC} is running! Close (M)anually or force to close (A)utomatically? (M/A): "
        #	read -p "" firefoxClose
        #	case $firefoxClose in
        #		[Aa]* )
        #			TryCloseFirefoxGracefully
        #		break;;
        #		[Mm]* ) break;;
        #	esac
        #done
    done
}

#need xdotool
function CloseFirefoxGracefully() {
    if [[ -n $(pidof firefox) ]]; then
        WID=$(xdotool search "Mozilla Firefox" | head -1)
        xdotool windowactivate --sync "$WID"
        xdotool key --clearmodifiers ctrl+q
    fi
}

function TryCloseFirefoxGracefully() {
    if [[ -n $(pidof firefox) ]]; then
        wmctrl -c Firefox
    fi
}

function simple_kill_firefox_gracefully() {
    pkill -f firefox
}

#THIS FUNCTION DOES NOT CARE ABOUT STRING VALUES TO INSERT. IF NEEDED, MUST FORCE "" ON VALUE. EX.: set_firefox_property "browser.download.lastDir" \"/home/sevendesktop/Downloads\"
#Function to insert or update settings into firefox config (pref.js)
#Example to set or create > user_pref("browser.cache.use_new_backend", 1);
#set_firefox_property "browser.cache.use_new_backend" 1
#$1: param
#$2: value
function set_firefox_property() {
    local valueSet="user_pref(\"${1}\", ${2});"
    if ! grep -q "${1}" "${firefox_config_file}"; then
        echo "${valueSet}" >> "${firefox_config_file}"
    else
        sed -i s/^.*"${1}".*$/"${valueSet}"/ "${firefox_config_file}"
    fi
}

function remove_firefox_property() {
    if grep -q "${1}" "${firefox_config_file}"; then
        sed -i "/${1}/d" "${firefox_config_file}"
    fi
}

function perform_install() {
    echo -e "${YELLOW}Applying $APPLICATION_NAME...${NC}"

    validate_firefox_running

    # New Firefox versions doesn't need this fix anymore #
    #echo -e "${ORANGE}Firefox config > CLOSE FIREFOX, BEFORE CONTINUE!${NC}"
    #read -p "Press any button to continue"
    #echo "Firefox > fix dark gnome themes, forcing using a white one for firefox, to avoid breaking page colors."
    ##https://askubuntu.com/questions/196652/how-to-disable-dark-theme-on-webpages-in-firefox
    #echo "File: /usr/lib/firefox/firefox.sh"
    #sed -i 's/export MOZ_APP_LAUNCHER/GTK_THEME=Adwaita:light\nexport GTK_THEME\nexport MOZ_APP_LAUNCHER/g' /usr/lib/firefox/firefox.sh

    firefox_config_file="$(get_firefox_config_file)"

    echo "Firefox > config file: $firefox_config_file"

    echo -e "Firefox > Performance > Automatically unload tabs on low memory"
    set_firefox_property "browser.tabs.unloadOnLowMemory" true

    echo -e "Firefox > Performance > Disable pocket"
    set_firefox_property "extensions.pocket.enabled" false

    echo -e "Firefox > Performance > Disable autoloading pinned tabs on start"
    echo "Reference: https://www.reddit.com/r/firefox/comments/hystz6/how_to_stop_pinned_tab_from_auto_reloading_on/"
    set_firefox_property "browser.sessionstore.restore_pinned_tabs_on_demand" true

    echo -e "Firefox > Performance > Reduce session history"
    echo "Reference: http://kb.mozillazine.org/Browser.sessionhistory.max_total_viewers"
    echo "Reference: https://wiki.mozilla.org/Mobile/MemoryReduction"
    set_firefox_property "browser.sessionhistory.max_entries" 5
    set_firefox_property "browser.sessionhistory.max_total_viewers" 4

    echo -e "Firefox > Security > Enable HTTPS-Only Mode in all windows"
    set_firefox_property "dom.security.https_only_mode" true

    echo -e "Firefox > Security > Enable DNS over HTTPS using Increased Protection (Cloudflare)"
    set_firefox_property "network.trr.mode" 2
    set_firefox_property "doh-rollout.disable-heuristics" true

    echo -e "Firefox > Performance & Privacy > Enhanced Tracking Protection > Strict: Strong protection, but may cause some sites or content to break"
    set_firefox_property "browser.contentblocking.category" "strict"
    set_firefox_property "privacy.annotate_channels.strict_list.enabled" true

    echo -e "Firefox > Privacy > Tell websites not sell or share my data"
    set_firefox_property "privacy.globalprivacycontrol.enabled" true

    echo -e "Firefox > Privacy > Send websites a 'Do Not Track' request"
    set_firefox_property "privacy.donottrackheader.enabled" true

    echo -e "Firefox > Usability > Zooming only for the current tab"
    echo "Reference: https://kb.mozillazine.org/Browser.zoom.siteSpecific"
    echo "Reference: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/browserSettings/zoomSiteSpecific"
    set_firefox_property "browser.zoom.siteSpecific" false

    echo -e "Firefox > Usability > Enable spellchecker for multi-line controls and single-line controls"
    echo "Reference: https://kb.mozillazine.org/Layout.spellcheckDefault"
    set_firefox_property "layout.spellcheckDefault" 2

    echo -e "Firefox > Usability > Downloads > Always ask you where to save files"
    set_firefox_property "browser.download.useDownloadDir" false

    echo -e "Firefox > Usability > Digital Rights Management (DRM) Content > Play DRM-controlled content"
    set_firefox_property "media.eme.enabled" true

    echo -e "Firefox > Themes > Tabs in title bar (disable title bar)"
    set_firefox_property "browser.tabs.inTitlebar" 1

    # echo -e "Firefox > Themes > Enable Alpenglow Theme"
    # set_firefox_property "extensions.activeThemeID" "firefox-alpenglow@mozilla.org"

    echo -e "Firefox > Themes > Enable Dark Theme"
    set_firefox_property "browser.theme.content-theme" 0
    set_firefox_property "extensions.activeThemeID" "firefox-compact-dark"

}

function perform_uninstall() {
    echo -e "${RED}Resetting $APPLICATION_NAME...${NC}"

    remove_firefox_property "browser.tabs.unloadOnLowMemory"
    remove_firefox_property "extensions.pocket.enabled"
    remove_firefox_property "browser.sessionstore.restore_pinned_tabs_on_demand"
    remove_firefox_property "browser.sessionhistory.max_entries"
    remove_firefox_property "browser.sessionhistory.max_total_viewers"
    remove_firefox_property "dom.security.https_only_mode"
    remove_firefox_property "network.trr.mode"
    remove_firefox_property "doh-rollout.disable-heuristics"
    remove_firefox_property "browser.contentblocking.category"
    remove_firefox_property "privacy.annotate_channels.strict_list.enabled"
    remove_firefox_property "privacy.globalprivacycontrol.enabled"
    remove_firefox_property "privacy.donottrackheader.enabled"
    remove_firefox_property "browser.zoom.siteSpecific"
    remove_firefox_property "layout.spellcheckDefault"
    remove_firefox_property "browser.download.useDownloadDir"
    remove_firefox_property "media.eme.enabled"
    remove_firefox_property "browser.tabs.inTitlebar"
    remove_firefox_property "browser.theme.content-theme"
    remove_firefox_property "extensions.activeThemeID"
}

function perform_check() {
    package_is_installed=2
    echo $package_is_installed
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
