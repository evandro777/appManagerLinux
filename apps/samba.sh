#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Configure Samba${NC}"

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/essentials.sh"
. "../includes/root_restrict_but_sudo.sh"

sudo apt-get -y update
sudo apt-get -y install samba

shareFolder="${HOME}/Public"
mkdir -p "$shareFolder"
sudo chmod 777 "$shareFolder"

sambaConf="/etc/samba/smb.conf"

#backup
#sudo cp "$sambaConf" "/etc/samba/smb.conf.bk"


#Prepare file to use crudini
#Remove white spaces on the beginning
sudo sed -i 's/^[ \t]*//;s/[ \t]*$//' "$sambaConf"

#Setting conf
#Symlinks & cache
sudo crudini --set "$sambaConf" "global" "follow symlinks" "yes"
sudo crudini --set "$sambaConf" "global" "wide links" "yes"
sudo crudini --set "$sambaConf" "global" "getwd cache" "yes"

#Security
sudo crudini --set "$sambaConf" "global" "client min protocol" "SMB2" #avoid SMB1 for security reasons

#Compatibility
sudo crudini --set "$sambaConf" "global" "unix extensions" "no"

#Avoid permissions problem
#sudo crudini --set "$sambaConf" "global" "guest only" "yes" #Apparently not necessary
sudo crudini --set "$sambaConf" "global" "force user" "$USER"
#sudo crudini --set "$sambaConf" "global" "force group" "$USER" #Apparently not necessary
sudo crudini --set "$sambaConf" "global" "create mode" "0664"
sudo crudini --set "$sambaConf" "global" "directory mode" "0775"

#Apparently not necessary
#sudo crudini --set "$sambaConf" "global" "unix charset" "UTF-8"
#sudo crudini --set "$sambaConf" "global" "server min protocol" "NT1"
#sudo crudini --set "$sambaConf" "global" "ntlm auth" "yes"
#sudo crudini --set "$sambaConf" "global" "bind interfaces only" "yes"

#READ & WRITE ALL
#INSTEAD OF THIS, USE NEMO SHARING
#sudo crudini --set "$sambaConf" "Files" "path" "$shareFolder"
#sudo crudini --set "$sambaConf" "Files" "available" "yes" #enable/disable sharing
#sudo crudini --set "$sambaConf" "Files" "writable" "yes"
#sudo crudini --set "$sambaConf" "Files" "guest ok" "yes"
#sudo crudini --set "$sambaConf" "Files" "guest only" "yes"
#sudo crudini --set "$sambaConf" "Files" "create mode" "0777"
#sudo crudini --set "$sambaConf" "Files" "directory mode" "0777"


#Prepare file to conf pattern
#Add white spaces on the beginning
sudo sed -i 's/^/   /' "$sambaConf"

#Remove white spaces on the beginning with "["
sudo sed -i 's/^   \[/\[/' "$sambaConf"

#Remove white spaces on the beginning with "#"
sudo sed -i 's/^   #/#/' "$sambaConf"

#Remove white spaces on the beginning with ";"
sudo sed -i 's/^   ;/;/' "$sambaConf"


#Permissions
#PROBABLY NEEDS THIS: MAYBE NEED TO FORCE THE SAME PASSWORD AS THE LOGGED USER

echo -e "${ORANGE}Set samba password for user $USER ${NC}"
sudo smbpasswd -a "$USER"

echo -e "${GREEN}When needed to change the password execute: ${NC}"
echo -e "sudo smbpasswd -a \$USER"


#sudo smbpasswd -e "$USER"

sudo systemctl restart smbd nmbd

#sudo ufw allow samba

echo -e "Samba installed & configured"
echo -e "${GREEN}An easy way to share is:${NC}"
echo -e "${GREEN}    * Use nemo and go to a folder (like home: $HOME)${NC}"
echo -e "${GREEN}    * Right click on the folder (like: Public) to share > Sharing options${NC}"
echo -e "${GREEN}    * Share this folder > Create share${NC}"
echo -e ""
echo -e "${Orange}The network login will be ${USER}${NC}"
