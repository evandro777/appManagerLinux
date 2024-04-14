#!/bin/bash

readonly APPLICATION_NAME="Settings > Performance > fstab > noatime: disables writing file access times"
readonly SET_OPTIONS="noatime"
readonly FSTAB="/etc/fstab"
readonly FSTAB_BACKUP="/etc/fstab.backup"

function perform_install() {
    echo -e "${YELLOW}Apply $APPLICATION_NAME...${NC}"

    echo -e "${RED}Creating fstab backup $FSTAB_BACKUP${NC}"
    sudo cp "$FSTAB" "$FSTAB_BACKUP"

    # Iterate over each line in the fstab file
    while IFS= read -r line; do
        # Extract the filesystem type and options from the line
        local filesystem=$(echo "$line" | awk '{print $3}')
        local options=$(echo "$line" | awk '{print $4}')

        # Check if the filesystem is compatible with noatime
        case $filesystem in
            ext2 | ext3 | ext4 | xfs | btrfs)
                # Add the noatime option if it's not already present
                if [[ ! "$options" =~ "noatime" ]]; then
                    new_options="$SET_OPTIONS,$options"
                    sudo sed -i "/$filesystem/s/\(^\S*\s*\S*\s*\S*\s*\)$options/\1$new_options/" "$FSTAB"
                    echo "Option $SET_OPTIONS successfully added to entry: $line"
                fi
                ;;
            *) ;;
        esac
    done < "$FSTAB_BACKUP"
}

function perform_uninstall() {
    echo -e "${RED}Reset $APPLICATION_NAME...${NC}"

    # Remove all instances of "noatime" from the fstab file
    sudo sed -i "s/\b$SET_OPTIONS\b,//g" "$FSTAB"

    echo "All instances of '$SET_OPTIONS' removed from $FSTAB."
}

function perform_check() {
    # Check if noatime is present in the fstab file
    if grep -q "\<$SET_OPTIONS\>" "$FSTAB"; then
        echo 1
    else
        echo 0
    fi
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
