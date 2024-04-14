#!/bin/bash

readonly APPLICATION_NAME="Drivers (doesn't have uninstall script!) & Nvidia + API VA-API + API VDPAU + patches (NVENC + NVFBC) [unofficial Git / don't auto update]"
readonly APPLICATION_ID="vdpau-driver-alla"
readonly SEARCH_DRIVERS="$(ubuntu-drivers devices)"

function is_patches_applied() {
    local IS_PATCHES_APPLIED=0
    if ffmpeg -loglevel error -y -t 1 -vsync 0 -hwaccel cuda -hwaccel_output_format cuda \
        -f lavfi -i testsrc \
        -vf hwupload -c:a copy -c:v h264_nvenc -b:v 4M -f null - \
        -vf hwupload -c:a copy -c:v h264_nvenc -b:v 1M -f null - \
        -vf hwupload -c:a copy -c:v h264_nvenc -b:v 8M -f null - \
        -vf hwupload -c:a copy -c:v h264_nvenc -b:v 6M -f null - \
        -vf hwupload -c:a copy -c:v h264_nvenc -b:v 5M -f null - \
        -vf hwupload -c:a copy -c:v h264_nvenc -b:v 7M -f null - \
        2> /dev/null; then

        IS_PATCHES_APPLIED=1
    fi
    echo "$IS_PATCHES_APPLIED"
}

recommended_drivers=$(echo "${SEARCH_DRIVERS}" | grep 'recommended' | awk '{print $3}')
recommended_nvidia_version=$(echo "${recommended_drivers}" | grep 'nvidia' | awk '{print $3}' | cut -d '-' -f 3)
installed_nvidia_version=$(dpkg -l | grep nvidia-driver | awk '{print $2}' | cut -d '-' -f 3)
is_latest_nvidia_driver_installed=1
if [ -n "$installed_nvidia_version" ] && [ -n "$recommended_nvidia_version" ]; then
    if ((installed_nvidia_version < recommended_nvidia_version)); then
        is_latest_nvidia_driver_installed=0
    fi
fi

function perform_install() {
    if [ "$is_latest_nvidia_driver_installed" -eq 0 ]; then
        echo -e "${YELLOW}Installing recommended (tested) driver${NC}"
        sudo ubuntu-drivers install
    fi
    if [ -n "$installed_nvidia_version" ]; then
        echo -e "${YELLOW}Installing VDPAU API (Video Decode and Presentation API for Unix) and uninstall translator VDPAU -> VA-API (not necessary for Nvidia)${NC}"
        package_install "$APPLICATION_ID"
        sudo apt-get purge -y libvdpau-va-gl1

        # If patches are applied
        if [ "$(is_patches_applied)" -eq 1 ]; then
            echo -e "${YELLOW}NVENC and NVFBC are already applied!${NC}"
            exit 0
        else
            echo -e "${YELLOW}Applying Nvidia Driver Patches: https://github.com/keylase/nvidia-patch/${NC}"

            PATCH_TEMP_FOLDER="/tmp/nvidia-patch"

            git clone --depth=1 https://github.com/keylase/nvidia-patch.git "${PATCH_TEMP_FOLDER}"

            echo "NVENC patch removes restriction on maximum number of simultaneous NVENC video encoding sessions imposed by Nvidia to consumer-grade GPUs."
            sudo bash "${PATCH_TEMP_FOLDER}"/patch.sh
            sudo bash "${PATCH_TEMP_FOLDER}"/patch.sh -f

            echo "NVFBC patch allows to use NVFBC on consumer-grade GPUs"
            sudo bash "${PATCH_TEMP_FOLDER}"/patch-fbc.sh
            sudo bash "${PATCH_TEMP_FOLDER}"/patch-fbc.sh -f
        fi
    fi
}

# function perform_uninstall() {
#     package_uninstall "$APPLICATION_ID"
# }

function perform_check() {
    if [ -z "$recommended_drivers" ]; then
        # Force status "3", status for "not available" (doesn't have any app/driver to install or is already installed)
        package_is_installed=3
    else
        package_is_installed=$(package_is_installed "$APPLICATION_ID")
        if [ "$package_is_installed" -eq 1 ]; then
            if [ "$(package_is_installed vdpau-driver-all)" -eq 0 ]; then
                package_is_installed=0
            elif [ "$(is_patches_applied)" -eq 0 ]; then
                package_is_installed=0
            elif [ "$is_latest_nvidia_driver_installed" -eq 0 ]; then
                package_is_installed=0
            fi
        fi
        # Force status "3", status for "not available" (doesn't have any app/driver to install or is already installed)
        if [ "$package_is_installed" -eq 1 ]; then
            package_is_installed=3
        # Force status "2", status for "apply only" that only apply and doesn't have uninstall script
        elif [ "$package_is_installed" -eq 0 ]; then
            package_is_installed=2
        fi
    fi

    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
