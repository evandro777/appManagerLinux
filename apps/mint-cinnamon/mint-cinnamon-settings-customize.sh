#!/bin/bash

readonly APPLICATION_NAME="Mint Cinnamon > Settings > Dark theme, +shortcuts, other settings"
readonly DISABLE_MOUSE_ACCELERATION='Section "InputClass"
    Identifier "My Mouse"
    Driver "libinput"
    MatchIsPointer "yes"
    Option "AccelProfile" "flat"
    Option "AccelSpeed" "0"
EndSection'
readonly LOGIN_SETTINGS_FILE="/etc/lightdm/slick-greeter.conf"

function perform_install() {
    echo "Cinnamon > Update Manager > show more informations"
    gsettings set com.linuxmint.updates show-size-column true
    gsettings set com.linuxmint.updates show-old-version-column true
    gsettings set com.linuxmint.updates show-origin-column true
    gsettings set com.linuxmint.updates autorefresh-hours 3

    echo "Cinnamon > Software Manager > Allow unverified flatpaks"
    gsettings set com.linuxmint.install allow-unverified-flatpaks true

    echo "Cinnamon > Setting maximum compression for file-roller"
    gsettings set org.gnome.FileRoller.General compression-level "maximum" # POSSIBLE VALUES: fast, normal, maximum

    echo "Cinnamon > Enable desktop trash icon"
    gsettings set org.nemo.desktop trash-icon-visible true

    echo "Cinnamon > Notifications on the bottom side of the screen"
    gsettings set org.cinnamon.desktop.notifications bottom-notifications true

    ## THEME > Mint-Y-Dark
    echo "Cinnamon > Theme > Mint-Y-Dark theme with transparency panel"
    mkdir -p "${HOME}/.themes/"
    cp -r /usr/share/themes/Mint-Y-Dark/ "$HOME/.themes/Mint-Y-Dark-Transparency/" # create a new theme based on original one

    echo "Cinnamon > Theme > Qt Apps > Force dark themes"
    sudo apt-get install -y qt5-style-plugins
    set_property "/etc/environment" "QT_QPA_PLATFORMTHEME" "gtk2"

    # Manually look for: .menu {
    # Change panel background color, and add transparency #Mint 20.x
    sed -i s/"  background-color: rgba(48, 49, 48, 0.99);"$/"  background-color: rgba(0, 0, 0, 0.2);"/ "$HOME/.themes/Mint-Y-Dark-Transparency/cinnamon/cinnamon.css"

    # Change panel background color, and add transparency #Mint 21.x
    sed -i s/"  background-color: rgba(47, 47, 47, 0.99);"$/"  background-color: rgba(0, 0, 0, 0.2);"/ "$HOME/.themes/Mint-Y-Dark-Transparency/cinnamon/cinnamon.css"

    gsettings set org.cinnamon.desktop.interface gtk-theme "Mint-Y-Dark"
    gsettings set org.cinnamon.desktop.interface icon-theme "Mint-Y-Yaru"
    gsettings set org.cinnamon.desktop.wm.preferences theme "Mint-Y"
    #gsettings set org.cinnamon.theme name "Mint-Y-Dark" #original
    gsettings set org.cinnamon.theme name "Mint-Y-Dark-Transparency" #modified with panel transparency

    echo "Cinnamon > Theme > Prefer dark mode"
    gsettings set org.x.apps.portal color-scheme "prefer-dark"

    ## NOTEBOOK
    echo "Cinnamon > Notebook > Disable reverse rolling"
    gsettings set org.cinnamon.desktop.peripherals.touchpad natural-scroll false

    echo "Cinnamon > Notebook > On battery power > Turn off screen when inactive for 5 minutes"
    gsettings set org.cinnamon.settings-daemon.plugins.power sleep-display-battery 300

    echo "Cinnamon > Notebook > On battery power > Suspend when inactive for 15 minutes"
    gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-timeout 900

    #echo "Notebook > On battery power > When lid is closed, do nothing"
    #gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-battery-action "nothing"

    #echo "Notebook > On A/C power > When lid is closed, do nothing"
    #gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-ac-action "nothing"

    ## NEMO

    echo "Cinnamon > Nemo > ignore per-folder view preferences"
    gsettings set org.nemo.preferences ignore-view-metadata true

    echo "Cinnamon > Nemo > Show tooltips in icon and compact views"
    gsettings set org.nemo.preferences tooltips-in-icon-view true

    echo "Cinnamon > Nemo > Detailed file type"
    gsettings set org.nemo.preferences tooltips-show-file-type true

    echo "Cinnamon > Nemo > Plugins (Disable 'ChangeColorFolder' for performance on navigate folders)"
    gsettings set org.nemo.plugins disabled-extensions '["EmblemPropertyPage+NemoPython", "PastebinitExtension+NemoPython", "NemoFilenameRepairer", "ChangeColorFolder+NemoPython"]'

    ## SHORTCUTS

    echo "Cinnamon > Keyboard Shortcut > Special key to move and resize windows (avoid conflict with some apps): Super + Left click"
    gsettings set org.cinnamon.desktop.wm.preferences mouse-button-modifier "<Super>"

    echo "Cinnamon > Keyboard Shortcut > Run command: Super + r"
    gsettings set org.cinnamon.desktop.keybindings.wm panel-run-dialog '["<Alt>F2", "<Super>r"]'

    echo "Cinnamon > Keyboard Shortcut > Media > Volume Down: ALT + SUPER + -"
    gsettings set org.cinnamon.desktop.keybindings.media-keys volume-down '["XF86AudioLowerVolume", "<Alt><Super>KP_Subtract"]'

    echo "Cinnamon > Keyboard Shortcut > Media > Volume Up: ALT + SUPER + +"
    gsettings set org.cinnamon.desktop.keybindings.media-keys volume-up '["XF86AudioRaiseVolume", "<Alt><Super>KP_Add"]'

    echo "Cinnamon > Keyboard Shortcut > Media > Play/Pause: ALT + SUPER + 5"
    echo "Cinnamon > Keyboard Shortcut > Media > Play/Pause: ALT + SUPER + i"
    gsettings set org.cinnamon.desktop.keybindings.media-keys play '["XF86AudioPlay", "<Alt><Super>KP_5", "<Alt><Super>i"]'

    echo "Cinnamon > Keyboard Shortcut > Media > Next: ALT + SUPER + 6"
    echo "Cinnamon > Keyboard Shortcut > Media > Next: ALT + SUPER + o"
    gsettings set org.cinnamon.desktop.keybindings.media-keys next '["XF86AudioNext", "<Alt><Super>KP_6", "<Alt><Super>o"]'

    echo "Cinnamon > Keyboard Shortcut > Media > Previous: ALT + SUPER + 4"
    echo "Cinnamon > Keyboard Shortcut > Media > Previous: ALT + SUPER + u"
    gsettings set org.cinnamon.desktop.keybindings.media-keys previous '["XF86AudioPrev", "<Alt><Super>KP_4", "<Alt><Super>u"]'

    echo "Cinnamon > Keyboard Shortcut > New > System Monitor: CTRL + SHIFT + ESC"
    set_new_keybinding "System Monitor" "gnome-system-monitor" "'<Primary><Shift>Escape'"

    echo "Cinnamon > Keyboard Shortcut > New > xkill: CTRL + ALT + X"
    set_new_keybinding "xkill" "xkill" "'<Primary><Super>x'"

    echo "Cinnamon > Keyboard Shortcut > New > System Info: SUPER + Pause"
    set_new_keybinding "System Info" "cinnamon-settings info" "'<Super>Pause'"

    echo "Cinnamon > Keyboard Shortcut > Removing shortcut for workspace > <Control><Shift><Alt>Up|Down > Conflict with VS Code Duplicate Lines (Copy lines up|down)"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up '["<Super><Shift>Page_Up"]'
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down '["<Super><Shift>Page_Down"]'
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up '["<Super>Page_Up"]'
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down '["<Super>Page_Down"]'

    echo "Cinnamon > Disabling mouse middle-click paste > Avoid problems with sites like figma, diagrams. Which use middle-click to drag"
    gsettings set org.gnome.desktop.interface gtk-enable-primary-paste false

    echo "Cinnamon > Disabling mouse acceleration"
    echo "${RED}If mouse movement is not good, try switching the acceleration${NC}"
    echo "${RED}System settings > Mouse and Touchpad: Switch acceleration type to 'Device default' or another${NC}"

    echo "${DISABLE_MOUSE_ACCELERATION}" | sudo tee /usr/share/X11/xorg.conf.d/50-mouse-acceleration.conf > /dev/null

    gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'
    gsettings set org.cinnamon.desktop.peripherals.mouse accel-profile 'flat'

    gsettings set org.gnome.desktop.peripherals.mouse speed 0.0
    gsettings set org.cinnamon.desktop.peripherals.mouse speed 0.0

    echo "Cinnamon > Logon > Enable numlock and Dark theme"
    sudo crudini --set "${LOGIN_SETTINGS_FILE}" Greeter activate-numlock "true"
    sudo crudini --set "${LOGIN_SETTINGS_FILE}" Greeter theme-name "Mint-Y-Dark"
    sudo crudini --set "${LOGIN_SETTINGS_FILE}" Greeter icon-theme-name "Mint-Y-Yaru"
}

function perform_uninstall() {
    gsettings reset-recursively com.linuxmint.updates
    gsettings reset-recursively com.linuxmint.install

    gsettings reset-recursively org.x.editor.preferences.editor

    gsettings reset org.gnome.FileRoller.General compression-level
    gsettings reset org.nemo.desktop trash-icon-visible
    gsettings reset org.cinnamon.desktop.notifications bottom-notifications

    gsettings reset org.cinnamon.desktop.interface gtk-theme
    gsettings reset org.cinnamon.desktop.interface icon-theme
    gsettings reset org.cinnamon.desktop.wm.preferences theme
    gsettings reset org.cinnamon.theme name
    remove_property "/etc/environment" "QT_QPA_PLATFORMTHEME"

    gsettings reset org.cinnamon.desktop.peripherals.touchpad natural-scroll
    gsettings reset-recursively org.cinnamon.settings-daemon.plugins.power
    gsettings reset-recursively org.nemo.preferences
    gsettings reset org.nemo.plugins disabled-extensions
    gsettings reset org.cinnamon.desktop.wm.preferences mouse-button-modifier
    gsettings reset-recursively org.cinnamon.desktop.keybindings
    gsettings reset-recursively org.gnome.desktop.wm.keybindings
    gsettings reset-recursively org.gnome.desktop.peripherals.mouse
    gsettings reset-recursively org.cinnamon.desktop.peripherals.mouse

    sudo rm -f /usr/share/X11/xorg.conf.d/50-mouse-acceleration.conf

    sudo crudini --set "${LOGIN_SETTINGS_FILE}" Greeter activate-numlock "false"
    sudo crudini --set "${LOGIN_SETTINGS_FILE}" Greeter theme-name "Mint-Y-Dark"
    sudo crudini --set "${LOGIN_SETTINGS_FILE}" Greeter icon-theme-name "Mint-Y-Yaru"
}

function perform_check() {
    package_is_installed=0
    # Determine if this script is applied by looking at the custom theme name "*-Transparency"
    if [[ "$(gsettings get org.cinnamon.theme name)" == *"-Transparency'" ]]; then
        package_is_installed=1
    fi
    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/mint-cinnamon-helper.sh" # Include file
. "$DIR/../../includes/header_packages.sh"

exit 0
