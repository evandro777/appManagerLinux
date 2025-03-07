#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/essentials.sh"
if [ $EUID == "0" ]; then
    echo "Must not be run as root!" 1>&2
    exit 1
fi

# Help function
show_help() {
    local packageName="${1}"

    echo "Usage: $0 [install [options] | uninstall | check | help]"
    echo "install        Install the ${packageName} package"
    echo "uninstall      Uninstall the ${packageName} package"
    echo "check          Check if the ${packageName} package is installed. 0: Not installed, 1: Installed, 2: Apply only (doesn't have uninstall), 3: Not available"
    echo "name           Application name"
    echo "get-parameters Prompt and generate parameters for silent install"
    echo "help           Display this help message"
    echo "Extra options:"
    echo "--dont-update => Do not execute apt-get update"
}

# Check for passed parameters
if [ $# -eq 0 ]; then
    # No parameters provided, ask for action

    # Check if the package is installed
    if [ "$(perform_check)" -eq 1 ]; then
        # Package is installed, ask if the user wants to uninstall
        echo -e -n "Do you want to ${RED}uninstall${NC} $APPLICATION_NAME? (Y/N): "
        read -r answer
        if [ "$answer" = "Y" ] || [ "$answer" = "y" ]; then
            echo -e "${RED}Uninstalling $APPLICATION_NAME...${NC}"
            perform_uninstall
        else
            echo "No action taken. Exiting."
            exit 1
        fi
    elif [ "$(perform_check)" -eq 0 ]; then
        # Package is not installed, ask if the user wants to install
        echo -e -n "Do you want to ${GREEN}install${NC} $APPLICATION_NAME? (Y/N): "
        read -r answer
        if [ "$answer" = "Y" ] || [ "$answer" = "y" ]; then
            echo -e "${YELLOW}Installing $APPLICATION_NAME...${NC}"
            package_update
            perform_install
        else
            echo "No action taken. Exiting."
            exit 1
        fi
    fi

    exit 0
fi

# Process the given parameter
case $1 in
    install)
        echo -e "${YELLOW}Installing $APPLICATION_NAME...${NC}"
        if [ -n "$IS_APT_PACKAGE" ] && [[ "$*" != *"--dont-update"* ]]; then
            package_update
        fi

        # Store the parameters in an associative array
        declare -A install_params

        # Iterate over the command-line arguments
        for arg in "$@"; do
            # Check if the argument starts with "--" and contains "="
            if [[ "$arg" == --*=* ]]; then
                # Extract key and value
                key="${arg#--}"         # Remove "--" from the beginning
                key="${key%%=*}"        # Get only the key before "="
                value="${arg#*=}"       # Get the value after "="
                value="${value//\"/}"   # Remove quotes if present
                install_params["$key"]="$value"  # Store in associative array
            fi
        done

        perform_install install_params
        # perform_install "$@"
        ;;
    uninstall)
        echo -e "${RED}Uninstalling $APPLICATION_NAME...${NC}"
        perform_uninstall
        ;;
    check)
        perform_check
        ;;
    name)
        echo "$APPLICATION_NAME"
        ;;
    get-parameters)
        if type get_parameters &> /dev/null; then
            get_parameters
        fi
        ;;
    help)
        if type -t overwrite_show_help > /dev/null; then
            overwrite_show_help "$APPLICATION_NAME"
        else
            show_help "$APPLICATION_NAME"
        fi
        ;;
    *)
        echo "Invalid option. Use 'help' for help."
        exit 1
        ;;
esac
