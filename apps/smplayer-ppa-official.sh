#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="SMPlayer [official PPA +custom configs]"
readonly APPLICATION_ID="smplayer"
readonly APPLICATION_PPA=ppa:rvm/smplayer

function perform_install() {
    sudo add-apt-repository -y $APPLICATION_PPA
    package_update
    package_install "$APPLICATION_ID"

    if [[ "$*" == *"--set-preferred-app"* ]]; then
        echo "Setting preferred application for $APPLICATION_NAME"
        set_preferred_app "$(get_video_mime_types)" "$APPLICATION_ID"
    fi

    echo "Starting smplayer first time to create default files"
    smplayer &
    pid=$! && sleep 7 && wmctrl -ic "$(wmctrl -lp | awk -vpid=$pid '$3==pid {print $1; exit}')" && sleep 3 # Wait for close

    echo "Applying custom configs"
    smplayer_ini_file="${HOME}/.config/smplayer/smplayer.ini"

    #SMPLAYER > CONFIG
    crudini --set "${smplayer_ini_file}" %General slang "pt-br,pt_BR,ptb,por,pt,eng,en"
    crudini --set "${smplayer_ini_file}" %General remember_media_settings false
    crudini --set "${smplayer_ini_file}" update_checker enabled false

    #nproc print number of cpu cores
    crudini --set "${smplayer_ini_file}" performance threads "$(nproc)"
    crudini --set "${smplayer_ini_file}" performance hwdec "auto"

    #SUBTITLES
    crudini --set "${smplayer_ini_file}" subtitles subcp "UTF-8"
    crudini --set "${smplayer_ini_file}" subtitles styles\\fontname "Ubuntu"
    crudini --set "${smplayer_ini_file}" subtitles styles\\fontsize 24
    crudini --set "${smplayer_ini_file}" subtitles styles\\primarycolor\\argb ffffff00

    #AUTOMATIC OPEN ALL VIDEO FILES IN PLAYLIST
    crudini --set "${smplayer_ini_file}" gui media_to_add_to_playlist 1

    #Save window size on exit
    crudini --set "${smplayer_ini_file}" gui save_window_size_on_exit false

    #Privacy
    crudini --set "${smplayer_ini_file}" directories latest_dir ""
    crudini --set "${smplayer_ini_file}" directories save_dirs false
    crudini --set "${smplayer_ini_file}" history recents\\max_items 0
    crudini --set "${smplayer_ini_file}" history urls\\max_items 0

    #SMPLAYER > Skin
    crudini --set "${smplayer_ini_file}" gui gui "DefaultGUI"
    crudini --set "${smplayer_ini_file}" gui iconset "Numix-remix"
    crudini --set "${smplayer_ini_file}" gui qt_style ""

    #SMPLAYER > MiniGUI Skin
    crudini --set "${smplayer_ini_file}" mini_gui pos "@Point(-10 -8)"
    crudini --set "${smplayer_ini_file}" mini_gui size "@Size(683 509)"
    crudini --set "${smplayer_ini_file}" mini_gui state 0
    crudini --set "${smplayer_ini_file}" mini_gui toolbars_state "@ByteArray(\0\0\0\xff\0\0\x12\xc7\xfd\0\0\0\x1\0\0\0\x3\0\0\0\0\0\0\0\0\xfc\x1\0\0\0\x1\xfb\0\0\0\x18\0p\0l\0\x61\0y\0l\0i\0s\0t\0\x64\0o\0\x63\0k\x2\0\0\0\0\0\0\0\0\0\0\0\x64\0\0\0\x1e\0\0\x2\xab\0\0\x1\xbe\0\0\0\x4\0\0\0\x4\0\0\0\b\0\0\0\b\xfc\0\0\0\x2\0\0\0\x3\0\0\0\0\0\0\0\x3\0\0\0\x1\0\0\0\x1a\0\x63\0o\0n\0t\0r\0o\0l\0w\0i\0\x64\0g\0\x65\0t\x1\0\0\0\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0)"
    crudini --set "${smplayer_ini_file}" mini_gui actions\\controlwidget "pl_prev, play_or_pause, pl_next, stop, separator, timeslider_action, separator, fullscreen, volumeslider_action"
    crudini --set "${smplayer_ini_file}" mini_gui actions\\floating_control "pl_prev, play_or_pause, pl_next, stop, separator, timeslider_action, separator, fullscreen, mute, volumeslider_action, separator, timelabel_action"
    crudini --set "${smplayer_ini_file}" mini_gui toolbars_icon_size\\controlwidget "@Size(24 24)"
    crudini --set "${smplayer_ini_file}" mini_gui toolbars_icon_size\\floating_control "@Size(24 24)"

    #SMPLAYER > Default GUI
    crudini --set "${smplayer_ini_file}" default_gui actions\\controlwidget\\1 "pl_prev, play_or_pause, pl_next, stop, separator, current_timelabel_action, timeslider_action, total_timelabel_action, separator, volumeslider_action, separator, subtitlestrack_menu, fullscreen"
    crudini --set "${smplayer_ini_file}" default_gui actions\\floating_control\\1 "pl_prev, play_or_pause, pl_next, stop, separator, current_timelabel_action, timeslider_action, total_timelabel_action, separator, volumeslider_action, separator, subtitlestrack_menu, fullscreen"
    crudini --set "${smplayer_ini_file}" default_gui actions\\controlwidget_mini\\1 "play_or_pause, stop, separator, timeslider_action, separator, mute, volumeslider_action"
    crudini --set "${smplayer_ini_file}" default_gui format_info true
    crudini --set "${smplayer_ini_file}" default_gui video_info true
    crudini --set "${smplayer_ini_file}" default_gui toolbars_state "@ByteArray(\0\0\0\xff\0\0\x19g\xfd\0\0\0\x1\0\0\0\x3\0\0\0\0\0\0\0\0\xfc\x1\0\0\0\x1\xfb\0\0\0\x18\0p\0l\0\x61\0y\0l\0i\0s\0t\0\x64\0o\0\x63\0k\x2\0\0\0\0\0\0\0\0\0\0\0\x64\0\0\0\x1e\0\0\x2\xab\0\0\x1\xa2\0\0\0\x4\0\0\0\x4\0\0\0\b\0\0\0\b\xfc\0\0\0\x2\0\0\0\x2\0\0\0\x1\0\0\0\x10\0t\0o\0o\0l\0\x62\0\x61\0r\0\x31\0\0\0\0\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\x3\0\0\0\x2\0\0\0\x1a\0\x63\0o\0n\0t\0r\0o\0l\0w\0i\0\x64\0g\0\x65\0t\x1\0\0\0\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0$\0\x63\0o\0n\0t\0r\0o\0l\0w\0i\0\x64\0g\0\x65\0t\0_\0m\0i\0n\0i\0\0\0\0\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0)"
    crudini --set "${smplayer_ini_file}" default_gui toolbars_icon_size\\controlwidget "@Size(32 32)"
}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"
    sudo add-apt-repository --remove --yes $APPLICATION_PPA
}

function perform_check() {
    package_is_installed "$APPLICATION_ID"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
