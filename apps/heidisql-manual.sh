#!/bin/bash

#COLORS
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${ORANGE}Installing HeidiSQL${NC}"

downloaded_file="/tmp/HeidiSQL.zip"

echo -e "${ORANGE}Paste the url for download the file (tip: only 32bit version allow to connect sqlserver)${NC}"
echo -e "Ex.: https://www.heidisql.com/downloads/releases/HeidiSQL_9.5_64_Portable.zip"
read -p "" url_download
wget "$url_download" -O "$downloaded_file"

path_to_install="$HOME"/App/HeidiSQL/

#CREATE FOLDER
mkdir -p -v "$path_to_install"

unzip "$downloaded_file" -d "$path_to_install"

#EXTRACT EXE RESOURCES
mkdir /tmp/extract_exe/
wrestool --extract --output=/tmp/extract_exe/ "${path_to_install}heidisql.exe"

#COPY ICON
cp /tmp/extract_exe/heidisql.exe_14_MAINICON.ico "${path_to_install}heidiSQL.ico"

#CONVERT ICO > PNG
#WILL EXTRACT TO heidiSQL-0.png, heidiSQL-1.png, heidiSQL-2.png, heidiSQL-3.png, heidiSQL-4.png, heidiSQL-5.png
#convert "${path_to_install}heidiSQL.ico" "${path_to_install}heidisql.png"
#EACH ONE
convert "${path_to_install}heidiSQL.ico[0]" "${path_to_install}heidisql-256.png"
convert "${path_to_install}heidiSQL.ico[1]" "${path_to_install}heidisql-128.png"
convert "${path_to_install}heidiSQL.ico[2]" "${path_to_install}heidisql-64.png"
convert "${path_to_install}heidiSQL.ico[3]" "${path_to_install}heidisql-48.png"
convert "${path_to_install}heidiSQL.ico[4]" "${path_to_install}heidisql-32.png"
convert "${path_to_install}heidiSQL.ico[5]" "${path_to_install}heidisql-16.png"

ICON_NAME=db-heidisql
TMP_DIR=`mktemp --directory`
DESKTOP_FILE=$TMP_DIR/db-heidisql.desktop
cat << EOF > $DESKTOP_FILE
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=HeidiSQL
GenericName=Database management
Keywords=sql,database,Postgre,MySQL
Comment=HeidiSQL 
Type=Application
Categories=Development
Terminal=false
StartupNotify=true
StartupWMClass=HeidiSQL
Exec=wine "${path_to_install}heidisql.exe"
MimeType=application/sql;text/sql;text/x-sql;text/plain
Icon=$ICON_NAME.png
EOF

# seems necessary to refresh immediately:
chmod 644 $DESKTOP_FILE

#cp "$DESKTOP_FILE" "${path_to_install}db-heidisql.desktop"

xdg-desktop-menu install $DESKTOP_FILE
xdg-icon-resource install --size 16 "${path_to_install}heidisql-16.png" $ICON_NAME
xdg-icon-resource install --size 32 "${path_to_install}heidisql-32.png" $ICON_NAME
xdg-icon-resource install --size 48 "${path_to_install}heidisql-48.png" $ICON_NAME
xdg-icon-resource install --size 64 "${path_to_install}heidisql-64.png" $ICON_NAME
xdg-icon-resource install --size 128 "${path_to_install}heidisql-128.png" $ICON_NAME
xdg-icon-resource install --size 256 "${path_to_install}heidisql-256.png" $ICON_NAME

rm $DESKTOP_FILE
rm -R $TMP_DIR

#Install additional libs for Microsoft SQL Server
winetricks mdac28 native_mdac

read -p "Press [Enter] to continue."
