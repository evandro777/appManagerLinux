#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Samba (windows network share) > caution: less restrictions"
readonly APPLICATION_ID="samba"

readonly SHARE_FOLDER_PARENT="${HOME}/Network share"
readonly SHARE_FOLDER_PUBLIC="${SHARE_FOLDER_PARENT}/Public"
readonly SHARE_FOLDER_READ="${SHARE_FOLDER_PARENT}/Read"
readonly SHARE_FOLDER_WRITE="${SHARE_FOLDER_PARENT}/Write"

readonly SAMBA_CONF="/etc/samba/smb.conf"
readonly SAMBA_CONF_BK="/etc/samba/smb.conf.bk"

function perform_install() {
    package_install "$APPLICATION_ID"

    create_folders_and_sharing

    echo "Sharings list:"
    net usershare info --long

    echo "Listing all local samba sharings"
    smbclient -L localhost -N

    # Access the associative array passed as a parameter
    declare -A params=$1
    create_samba_user $params

    set_samba_conf $params

    if command -v ufw &> /dev/null; then
        echo "UFW firewall detected. Creating exception rules"

        sudo ufw allow from 192.168.0.0/16 to any app Samba comment "Samba: Only local network"
        sudo ufw allow from 10.0.0.0/8 to any app Samba comment "Samba: Only local network"
        sudo ufw allow from 172.16.0.0/12 to any app Samba comment "Samba: Only local network"

        sudo ufw deny Samba comment "Samba: Only local network"

        echo "Showing UFW created rules"
        sudo ufw status | grep "Samba: Only local network"
    fi

    echo -e "Samba installed & configured"
    echo -e "${GREEN}An easy way to share is:${NC}"
    echo -e "${GREEN}    * Use nemo and go to a folder (like home: $HOME)${NC}"
    echo -e "${GREEN}    * Right click on the folder (like: Public) to share > Sharing options${NC}"
    echo -e "${GREEN}    * Share this folder > Create share${NC}"
    echo -e "${GREEN}Folders automatically shared:${NC}"
    echo -e "${GREEN}    * Everyone on network can access, read & write: ${SHARE_FOLDER_PUBLIC}${NC}"
    echo -e "${GREEN}    * Logged user (${USER}) on network can access and read: ${SHARE_FOLDER_READ}${NC}"
    echo -e "${GREEN}    * Logged user (${USER}) on network can access, read & write: ${SHARE_FOLDER_WRITE}${NC}"
    echo
    echo -e "${YELLOW}The network login will be:${NC}"
    echo -e "${YELLOW}Username:${NC} ${USER}"
    echo -e "${YELLOW}Domain:${NC} WORKGROUP"
    echo -e "${YELLOW}Password:${NC} 'The password set for Samba'"
    echo
    echo -e "${GREEN}Your hostname on local network is \"$(hostname).local\"${NC}"
    echo
    echo -e "${RED}Useful information:${NC}"
    echo -e "${GREEN}Folder that keep usershare config files: /var/lib/samba/usershares/${NC}"
    echo -e "${YELLOW}If only Public folder is working, might be a problem with user, execute these commands below:${NC}"
    echo 'net usershare add Write "${HOME}/Network share/Write" "Read and Write Shared Folder" "$(sudo net getlocalsid | awk ''{print $NF}'')-$(id -u):F"'
    echo 'net usershare add Read "${HOME}/Network share/Read" "Read-Only Shared Folder" "$(sudo net getlocalsid | awk ''{print $NF}'')-$(id -u):R"'

    # To list local network computers with samba shared: avahi-browse -rt _smb._tcp
    #     If you want a cleaner output: avahi-browse -rt _smb._tcp | grep -E "hostname|address" | awk -F'[][]' '{print $2}' | paste - - | awk '$2 ~ /^192\.168\./ || ($2 ~ /:/ && $2 !~ /^fe80:/ && $2 !~ /^::1$/ && $2 !~ /^127\./)'

}

function perform_uninstall() {
    package_uninstall "$APPLICATION_ID"

    echo "Folders will not be removed for safety"

    echo "Remove sharings: Public, Read & Write"
    net usershare delete Public
    net usershare delete Read
    net usershare delete Write

    echo "Remove sharing icon of: ${SHARE_FOLDER_PARENT}"
    gio set -t unset "${SHARE_FOLDER_PARENT}" metadata::custom-icon-name

    if command -v ufw &> /dev/null; then
        echo "UFW firewall detected. Removing exception rules"
        sudo ufw status numbered | grep "Samba: Only local network" | awk -F'[][]' '{print $2}' | sort -nr | while read -r rule; do
            yes | sudo ufw delete "$rule"
        done
    fi
}

function perform_check() {
    package_is_installed=$(package_is_installed "$APPLICATION_ID")
    if [ "$package_is_installed" -eq 1 ]; then
        # Verify if sharing was created with `net usershare list`
        if ! net usershare list | grep -qE "^(Public|Read|Write)$"; then
            package_is_installed=0
        fi
    fi

    echo "$package_is_installed"
}

function get_parameters() {
    # Don't use echo before read, it's not going to work to set into a variable "app-menu-init.sh"
    while true; do
        # quote using read is a problem using a variable and doesn't work with \n, so this is a workaround: '"$USER"$'
        read -rsp $'Type a password for ⚠️ Samba user ⚠️ ('"$USER"$'). Cannot be empty: \n' password
        if [[ -n "$password" ]]; then
            break # Exit loop if password is not empty
        fi
    done

    read -rp $'Enable wide links [y | n (default)]\nCaution: samba can follow symlinks anywhere, which can be dangerous. Default is no (safer): ' enable_wide_links

    echo "--samba-password=$password --samba-enable-wide-links=$enable_wide_links"
}

function create_folders_and_sharing() {
    echo "Creating and setting permissions on folder ${YELLOW}$SHARE_FOLDER_PUBLIC${NC}"
    echo "This folder everyone on network, even with anonymous user can access"
    mkdir -p "$SHARE_FOLDER_PUBLIC"
    sudo chmod 777 "$SHARE_FOLDER_PUBLIC"
    net usershare add Public "$SHARE_FOLDER_PUBLIC" "Public Shared Folder" "Everyone:F" guest_ok=y
    # Share permissions file: "0664" dir: "0775". Doesn't work with usershare

    echo "Creating and setting permissions on folder ${YELLOW}$SHARE_FOLDER_READ${NC}"
    echo "This folder only authenticated users can access: read only"
    mkdir -p "$SHARE_FOLDER_READ"
    sudo chmod 755 "$SHARE_FOLDER_READ"
    sudo chown "$USER:sambashare" "$SHARE_FOLDER_READ"
    net usershare add Read "$SHARE_FOLDER_READ" "Read-Only Shared Folder" "$USER:R"
    # Share permissions file: "0444" dir: "0555". Doesn't work with usershare

    echo "Creating and setting permissions on folder ${YELLOW}$SHARE_FOLDER_WRITE${NC}"
    echo "This folder only authenticated users can access: read and write"
    mkdir -p "$SHARE_FOLDER_WRITE"
    sudo chmod 770 "$SHARE_FOLDER_WRITE"
    sudo chown "$USER:sambashare" "$SHARE_FOLDER_WRITE"
    net usershare add Write "$SHARE_FOLDER_WRITE" "Read and Write Shared Folder" "$USER:F"
    # Share permissions file: "0664" dir: "0775". Doesn't work with usershare

    echo "Set sharing icon for ${SHARE_FOLDER_PARENT}"
    gio set "${SHARE_FOLDER_PARENT}" metadata::custom-icon-name folder-publicshare
}

function create_samba_user() {
    # Verifica se o usuário já existe no Samba
    if sudo pdbedit -L | grep -q "^$USER:"; then
        echo "User '$USER' already exists in Samba. Updating password..."
    else
        echo "Creating Samba user: $USER"
    fi

    # Access the associative array passed as a parameter
    local -n params=$1

    if [ -n "${params[samba\-password]}" ]; then
        password="${params[samba\-password]}"
    else
        while true; do
            read -rsp $'Type a password for ⚠️ Samba user ⚠️ ('$USER'): ' password
            echo # Add a linebreak
            if [[ -n "$password" ]]; then
                break # Exit loop if password is not empty
            fi
            echo "⚠️  Password cannot be empty! Please try again."
        done
    fi

    # explain: echo -e "$password\n$password" print password twice, because smbpasswd asks the password twice to confirm
    echo -e "$password\n$password" | sudo smbpasswd -a $USER

    echo -e "${GREEN}To change the password execute: ${NC}"
    echo -e "sudo smbpasswd -a $USER"
}

function set_samba_conf() {
    # Access the associative array passed as a parameter
    local -n params=$1

    echo "Creating smb.conf backup at (doesn't overwrite): $SAMBA_CONF_BK"
    sudo cp --update=none "$SAMBA_CONF" "$SAMBA_CONF_BK"

    # Documentation for smb.conf: https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html

    #Prepare file to use crudini
    #Remove white spaces on the beginning
    sudo sed -i 's/^[ \t]*//;s/[ \t]*$//' "$SAMBA_CONF"

    #Setting conf
    #Symlinks
    echo "Enable follow symlinks"
    sudo crudini --set "$SAMBA_CONF" "global" "follow symlinks" "yes"
    if [ -n "${params[samba\-enable\-wide\-links]}" ]; then
        echo "Enable wide links. Caution: samba can follow links anywhere, which can be dangerous"
        sudo crudini --set "$SAMBA_CONF" "global" "wide links" "yes"
    fi

    #Performance
    echo "Enable sendfile > Improve performance. Might have problems sharing NFS, CIFS or old SMB versions"
    sudo crudini --set "$SAMBA_CONF" "global" "use sendfile" "yes"
    echo "Disable strict locking > Improve performance. Avoid unnecessary file blocking"
    sudo crudini --set "$SAMBA_CONF" "global" "strict locking" "no"

    #Security
    echo "Set client min protocol: SMB3 > Useful for security and performance reasons. Windows 8+"
    sudo crudini --set "$SAMBA_CONF" "global" "client min protocol" "SMB3" #avoid SMB1 for security and performance reasons
    echo "Set server min protocol: SMB3 > Useful for security and performance reasons. Windows 8+"
    sudo crudini --set "$SAMBA_CONF" "global" "server min protocol" "SMB3" #avoid SMB1 for security and performance reasons
    echo "Disable ntlm auth > Useful for security reasons"
    sudo crudini --set "$SAMBA_CONF" "global" "ntlm auth" "no"


    #Compatibility
    echo "Disable unix extensions. Useful for better compatibility with windows. Enable Samba to better serve UNIX CIFS clients by supporting features such as symbolic links, hard links, etc. No current use to Windows clients"
    sudo crudini --set "$SAMBA_CONF" "global" "unix extensions" "no"
    echo "Set unix charset: UTF-8 > Useful for better compatibility"
    sudo crudini --set "$SAMBA_CONF" "global" "unix charset" "UTF-8"


    #Avoid permissions problem
    echo "Set guest account: $USER > Useful for anonymous access to public folder"
    sudo crudini --set "$SAMBA_CONF" "global" "guest account" "$USER"
    echo "Set create mode: 0664 and directory mode: 0775 > Some restrictions when creating file/directory from Samba"
    sudo crudini --set "$SAMBA_CONF" "global" "create mode" "0664"
    sudo crudini --set "$SAMBA_CONF" "global" "directory mode" "0775"
    #sudo crudini --set "$SAMBA_CONF" "global" "guest only" "yes" #Apparently not necessary
    #sudo crudini --set "$SAMBA_CONF" "global" "force user" "$USER"
    #sudo crudini --set "$SAMBA_CONF" "global" "force group" "$USER" #Apparently not necessary

    #Apparently not necessary
    #sudo crudini --set "$SAMBA_CONF" "global" "bind interfaces only" "yes"

    #READ & WRITE ALL
    #INSTEAD OF THIS, USE NEMO SHARING
    #sudo crudini --set "$SAMBA_CONF" "Files" "path" "$share_folder"
    #sudo crudini --set "$SAMBA_CONF" "Files" "available" "yes" #enable/disable sharing
    #sudo crudini --set "$SAMBA_CONF" "Files" "writable" "yes"
    #sudo crudini --set "$SAMBA_CONF" "Files" "guest ok" "yes"
    #sudo crudini --set "$SAMBA_CONF" "Files" "guest only" "yes"
    #sudo crudini --set "$SAMBA_CONF" "Files" "create mode" "0777"
    #sudo crudini --set "$SAMBA_CONF" "Files" "directory mode" "0777"

    #Prepare file to conf pattern
    #Add white spaces on the beginning
    sudo sed -i 's/^/   /' "$SAMBA_CONF"

    #Remove white spaces on the beginning with "["
    sudo sed -i 's/^   \[/\[/' "$SAMBA_CONF"

    #Remove white spaces on the beginning with "#"
    sudo sed -i 's/^   #/#/' "$SAMBA_CONF"

    #Remove white spaces on the beginning with ";"
    sudo sed -i 's/^   ;/;/' "$SAMBA_CONF"

    echo "Restarting samba"
    sudo systemctl restart smbd nmbd
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
