#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/essentials.sh"
. "../includes/root_restrict_but_sudo.sh"

echo -e "${ORANGE}Installing SMPlayer${NC}"

#SMPLAYER > OFFICIAL
sudo apt add-repository -y ppa:rvm/smplayer

apt update

#SMPLAYER > OFFICIAL THIRD-PARTY PPA
sudo apt install -y smplayer
	#EXECUTE FIRST TIME
	smplayer & pid=$! && sleep 7 && wmctrl -ic $(wmctrl -lp | awk -vpid=$pid '$3==pid {print $1; exit}') && sleep 3 # Wait for close

	smplayerIniFile="${HOME}/.config/smplayer/smplayer.ini"

	#REMOVED BELOW BECAUSE OF USING WITH sudo -u SUDO_USER, HAVE TO DO CHANGES, BECAUSE USING SUDO START ANOTHER PROCESS, WICH GET THE WRONG PID FOR CLOSE THE WINDOW
	#smplayer & pid=$!
	#KILL AFTER EXECUTE FIRST TIME
		#SIGTERM
		#sleep 7 && kill $pid
		#SIGKILL
		#sleep 7 && kill -9 $pid
		#KILL GRACEFULLY (ALT-F4)
			#Window Name
			#sleep 7 && wmctrl -F -c "SMPlayer"
			#PID
			#sleep 7 && wmctrl -ic $(wmctrl -lp | awk -vpid=$pid '$3==pid {print $1; exit}')

	#SMPLAYER > CONFIG
	crudini --set "${smplayerIniFile}" %General slang "pt-br,pt_BR,ptb,por,pt,eng,en"
	crudini --set "${smplayerIniFile}" %General remember_media_settings false
	crudini --set "${smplayerIniFile}" update_checker enabled false
	#nproc print number of cpu cores
	crudini --set "${smplayerIniFile}" performance threads $(nproc)
	crudini --set "${smplayerIniFile}" performance hwdec "auto"
	
	#SUBTITLES
	crudini --set "${smplayerIniFile}" subtitles subcp "UTF-8"
	crudini --set "${smplayerIniFile}" subtitles styles\\fontname "Ubuntu"
	crudini --set "${smplayerIniFile}" subtitles styles\\fontsize 24
	crudini --set "${smplayerIniFile}" subtitles styles\\primarycolor\\argb ffffff00
	
	#AUTOMATIC OPEN ALL VIDEO FILES IN PLAYLIST
	crudini --set "${smplayerIniFile}" gui media_to_add_to_playlist 1
	
	#Save window size on exit
	crudini --set "${smplayerIniFile}" gui save_window_size_on_exit false

	#Privacy
	crudini --set "${smplayerIniFile}" directories latest_dir ""
	crudini --set "${smplayerIniFile}" directories save_dirs false
	crudini --set "${smplayerIniFile}" history recents\\max_items 0
	crudini --set "${smplayerIniFile}" history urls\\max_items 0

	#SMPLAYER > MiniGUI
		#crudini --set "${smplayerIniFile}" gui iconset ""
		#crudini --set "${smplayerIniFile}" gui gui "MiniGUI"
		#crudini --set "${smplayerIniFile}" default_gui actions\controlwidget "play_or_pause, stop, separator, timeslider_action, separator, fullscreen, mute, volumeslider_action, pl_prev, pl_next"

	#SMPLAYER > SKINS (Modern Skin)
		#wget "https://downloads.sourceforge.net/project/smplayer/SMPlayer-themes/16.8.0/smplayer-themes-16.8.0.tar.bz2?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fsmplayer%2Ffiles%2FSMPlayer-themes%2F16.8.0%2F&ts=1484534756&use_mirror=ufpr" -O "/tmp/smplayer-themes-16.8.0.tar.bz2"
		#sudo mkdir /usr/share/smplayer/themes
		#tar -jxvf /tmp/smplayer-themes-16.8.0.tar.bz2 -C /tmp
		#mv /tmp/smplayer-themes-16.8.0/themes /usr/share/smplayer/themes

		#SMPLAYER > Skin
			crudini --set "${smplayerIniFile}" gui gui "DefaultGUI"
			crudini --set "${smplayerIniFile}" gui iconset "Numix-remix"
			crudini --set "${smplayerIniFile}" gui qt_style ""
					
		#SMPLAYER > MiniGUI Skin
			crudini --set "${smplayerIniFile}" mini_gui pos "@Point(-10 -8)"
			crudini --set "${smplayerIniFile}" mini_gui size "@Size(683 509)"
			crudini --set "${smplayerIniFile}" mini_gui state 0
			crudini --set "${smplayerIniFile}" mini_gui toolbars_state "@ByteArray(\0\0\0\xff\0\0\x12\xc7\xfd\0\0\0\x1\0\0\0\x3\0\0\0\0\0\0\0\0\xfc\x1\0\0\0\x1\xfb\0\0\0\x18\0p\0l\0\x61\0y\0l\0i\0s\0t\0\x64\0o\0\x63\0k\x2\0\0\0\0\0\0\0\0\0\0\0\x64\0\0\0\x1e\0\0\x2\xab\0\0\x1\xbe\0\0\0\x4\0\0\0\x4\0\0\0\b\0\0\0\b\xfc\0\0\0\x2\0\0\0\x3\0\0\0\0\0\0\0\x3\0\0\0\x1\0\0\0\x1a\0\x63\0o\0n\0t\0r\0o\0l\0w\0i\0\x64\0g\0\x65\0t\x1\0\0\0\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0)"
			crudini --set "${smplayerIniFile}" mini_gui actions\\controlwidget "pl_prev, play_or_pause, pl_next, stop, separator, timeslider_action, separator, fullscreen, volumeslider_action"
			crudini --set "${smplayerIniFile}" mini_gui actions\\floating_control "pl_prev, play_or_pause, pl_next, stop, separator, timeslider_action, separator, fullscreen, mute, volumeslider_action, separator, timelabel_action"
			crudini --set "${smplayerIniFile}" mini_gui toolbars_icon_size\\controlwidget "@Size(24 24)"
			crudini --set "${smplayerIniFile}" mini_gui toolbars_icon_size\\floating_control "@Size(24 24)"
			
		#SMPLAYER > Default GUI
			crudini --set "${smplayerIniFile}" default_gui actions\\controlwidget\\1 "pl_prev, play_or_pause, pl_next, stop, separator, current_timelabel_action, timeslider_action, total_timelabel_action, separator, volumeslider_action, separator, subtitlestrack_menu, fullscreen"
			crudini --set "${smplayerIniFile}" default_gui actions\\floating_control\\1 "pl_prev, play_or_pause, pl_next, stop, separator, current_timelabel_action, timeslider_action, total_timelabel_action, separator, volumeslider_action, separator, subtitlestrack_menu, fullscreen"
			crudini --set "${smplayerIniFile}" default_gui actions\\controlwidget_mini\\1 "play_or_pause, stop, separator, timeslider_action, separator, mute, volumeslider_action"
			crudini --set "${smplayerIniFile}" default_gui format_info true
			crudini --set "${smplayerIniFile}" default_gui video_info true
			crudini --set "${smplayerIniFile}" default_gui toolbars_state "@ByteArray(\0\0\0\xff\0\0\x19g\xfd\0\0\0\x1\0\0\0\x3\0\0\0\0\0\0\0\0\xfc\x1\0\0\0\x1\xfb\0\0\0\x18\0p\0l\0\x61\0y\0l\0i\0s\0t\0\x64\0o\0\x63\0k\x2\0\0\0\0\0\0\0\0\0\0\0\x64\0\0\0\x1e\0\0\x2\xab\0\0\x1\xa2\0\0\0\x4\0\0\0\x4\0\0\0\b\0\0\0\b\xfc\0\0\0\x2\0\0\0\x2\0\0\0\x1\0\0\0\x10\0t\0o\0o\0l\0\x62\0\x61\0r\0\x31\0\0\0\0\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\x3\0\0\0\x2\0\0\0\x1a\0\x63\0o\0n\0t\0r\0o\0l\0w\0i\0\x64\0g\0\x65\0t\x1\0\0\0\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0$\0\x63\0o\0n\0t\0r\0o\0l\0w\0i\0\x64\0g\0\x65\0t\0_\0m\0i\0n\0i\0\0\0\0\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0)"
			crudini --set "${smplayerIniFile}" default_gui toolbars_icon_size\\controlwidget "@Size(32 32)"
			
			#crudini --set "${smplayerIniFile}" default_gui state 2
