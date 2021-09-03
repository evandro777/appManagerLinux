#!/bin/bash
#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color
echo -e "${ORANGE}Configure Firefox${NC}"

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/essentials.sh"
. "../includes/root_restrict.sh"

#need xdotool
function CloseFirefoxGracefully(){
	if [[ -n `pidof firefox` ]];then
		WID=`xdotool search "Mozilla Firefox" | head -1`
		xdotool windowactivate --sync $WID
		xdotool key --clearmodifiers ctrl+q
	fi
}

function TryCloseFirefoxGracefully(){
	if [[ -n `pidof firefox` ]];then
		wmctrl -c Firefox
	fi
}

#THIS FUNCTION DOES NOT CARE ABOUT STRING VALUES TO INSERT. IF NEEDED, MUST FORCE "" ON VALUE. EX.: SetFirefoxProperty "browser.download.lastDir" \"/home/sevendesktop/Downloads\"
#Function to insert or update settings into firefox config (pref.js)
#Example to set or create > user_pref("browser.cache.use_new_backend", 1);
#SetFirefoxProperty "browser.cache.use_new_backend" 1
#$1: param
#$2: value
function SetFirefoxProperty(){
	local valueSet="user_pref(\"${1}\", ${2});"
	if ! grep -q "${1}" "${firefoxConfigFile}"; then
		echo "${valueSet}" >> "${firefoxConfigFile}"
	else
		sed -i s/^.*"${1}".*$/"${valueSet}"/ "${firefoxConfigFile}"
	fi
}

firefoxConfigFile=$(find ${HOME}/.mozilla/firefox/*/prefs.js)

if [[ "$firefoxConfigFile" == "" ]];then
	#EXECUTE FIRST TIME	
	firefox & pid=$! && sleep 7 && wmctrl -ic $(wmctrl -lp | awk -vpid=$pid '$3==pid {print $1; exit}') && sleep 3 # Wait for close
	firefoxConfigFile=$(find ${HOME}/.mozilla/firefox/*/prefs.js)
fi

echo "Firefox > config file:"
echo "$firefoxConfigFile"

###################################################################################################
##### APARENTEMENTE NOVAS VERSÕES DO FIREFOX, NÃO PRECISAM MAIS DESTE AJUSTE PARA TEMA ESCURO #####
###################################################################################################
#echo -e "${ORANGE}Firefox config > CLOSE FIREFOX, BEFORE CONTINUE!${NC}"
#read -p "Press any button to continue"
#echo "Firefox > fix dark gnome themes, forcing using a white one for firefox, to avoid breaking page colors."
##https://askubuntu.com/questions/196652/how-to-disable-dark-theme-on-webpages-in-firefox
#echo "File: /usr/lib/firefox/firefox.sh"
#sed -i 's/export MOZ_APP_LAUNCHER/GTK_THEME=Adwaita:light\nexport GTK_THEME\nexport MOZ_APP_LAUNCHER/g' /usr/lib/firefox/firefox.sh

process="firefox"
while pidof firefox "$process" >/dev/null; do
	while true; do
		echo -e "${ORANGE}Firefox${NC} is running! Close manually and press any key to continue: "
		read -p "" firefoxClose
		case $firefoxClose in
			* ) break;;
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

SetFirefoxProperty "browser.cache.use_new_backend" 1

SetFirefoxProperty "browser.sessionhistory.max_entries" 5

SetFirefoxProperty "browser.sessionhistory.max_total_viewers" 4

SetFirefoxProperty "browser.sessionstore.restore_pinned_tabs_on_demand" true

SetFirefoxProperty "browser.zoom.siteSpecific" false

SetFirefoxProperty "config.trim_on_minimize" true

SetFirefoxProperty "content.interrupt.parsing" true

SetFirefoxProperty "content.switch.threshold" 1000000

SetFirefoxProperty "layout.spellcheckDefault" 2

SetFirefoxProperty "network.http.pipelining" true

SetFirefoxProperty "network.http.pipelining.ssl" true

SetFirefoxProperty "network.http.proxy.pipelining" false

SetFirefoxProperty "browser.contentblocking.category" "strict"

SetFirefoxProperty "browser.startup.homepage" "about:home"

SetFirefoxProperty "media.eme.enabled" true

SetFirefoxProperty "network.cookie.cookieBehavior" 5

SetFirefoxProperty "pref.browser.homepage.disable_button.current_page" false

SetFirefoxProperty "pref.browser.homepage.disable_button.restore_default" false

SetFirefoxProperty "privacy.annotate_channels.strict_list.enabled" true

SetFirefoxProperty "privacy.sanitize.pending" "[]"

SetFirefoxProperty "privacy.trackingprotection.enabled" true

SetFirefoxProperty "privacy.trackingprotection.socialtracking.enabled" true

SetFirefoxProperty "browser.tabs.drawInTitlebar" true

SetFirefoxProperty "browser.urlbar.tipShownCount.searchTip_onboard" 4

SetFirefoxProperty "extensions.pocket.enabled" false

# Alpenglow Theme 
SetFirefoxProperty "browser.theme.toolbar-theme" 1
SetFirefoxProperty "extensions.activeThemeId" "firefox-alpenglow@mozilla.org"
