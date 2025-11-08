#!/bin/bash

readonly APPLICATION_NAME="Drivers (doesn't have uninstall script!)"
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
    sudo apt-get install -y -q vainfo
    if [ "$is_latest_nvidia_driver_installed" -eq 0 ]; then
        echo -e "${YELLOW}Installing recommended (tested) driver${NC}"
        sudo ubuntu-drivers install
    fi
    if [ -n "$installed_nvidia_version" ]; then
        echo "Nvidia + API VA-API + API VDPAU + patches (NVENC + NVFBC) [unofficial Git / don't auto update]"
        echo -e "${YELLOW}Installing VDPAU API (Video Decode and Presentation API for Unix) and uninstall translator VDPAU -> VA-API (not necessary for Nvidia)${NC}"
        package_install "vdpau-driver-all"
        sudo apt-get purge -y -q libvdpau-va-gl1

        echo "Installing nvidia-vaapi-driver. VA-API implementation that uses NVDEC as a backend. This implementation is specifically designed to be used by Firefox for accelerated decode of web content, and may not operate correctly in other applications"
        sudo apt-get install -y -q nvidia-vaapi-driver

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
    elif lspci | grep -qi 'VGA.*Intel'; then
        echo "Intel GPU detected - installing VAAPI drivers..."
        sudo apt-get install -y -q intel-gpu-tools intel-media-va-driver-non-free i965-va-driver-shaders

        # Optional: set environment variable for Intel VAAPI
        # if ! grep -q "LIBVA_DRIVER_NAME" /etc/environment; then
        #     echo "LIBVA_DRIVER_NAME=iHD" | sudo tee -a /etc/environment
        # fi

        echo "VAAPI driver installation complete."
        echo "Testing..."
        vainfo | grep -i "Driver version"
    fi
}

# function perform_uninstall() {
#     package_uninstall "$APPLICATION_ID"
# }

function perform_check() {
    # Force status "3", status for "not available" (doesn't have any app/driver to install or is already installed)
    package_is_installed=3
    if [ -n "$recommended_drivers" ]; then
        package_is_installed=$(package_is_installed "vdpau-driver-all")
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
    elif lspci | grep -qi 'VGA.*Intel'; then
        if [ "$(package_is_installed intel-gpu-tools)" -eq 0 ]; then
            package_is_installed=0
        elif [ "$(package_is_installed intel-media-va-driver-non-free)" -eq 0 ]; then
            package_is_installed=0
        elif [ "$(package_is_installed i965-va-driver-shaders)" -eq 0 ]; then
            package_is_installed=0
        fi
    fi

    echo "$package_is_installed"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
