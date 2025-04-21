#!/bin/bash

readonly IS_APT_PACKAGE=1
readonly APPLICATION_NAME="Variety [official PPA]"
readonly APPLICATION_ID="variety"
readonly APPLICATION_PPA=ppa:variety/stable

#default in: .config/variety/variety.conf
#[sources]
#src1 = True|favorites|The Favorites folder
#src2 = True|fetched|The Fetched folder
#src3 = True|folder|/usr/share/backgrounds
#src4 = True|flickr|user:www.flickr.com/photos/peter-levi/;user_id:93647178@N00;
#src5 = False|apod|NASA's Astronomy Picture of the Day
#src6 = False|bing|Bing Photo of the Day
#src7 = False|earthview|Google Earth View Wallpapers
#src8 = False|natgeo|National Geographic's photo of the day
#src9 = False|unsplash|High-resolution photos from Unsplash.com

function perform_install() {
    sudo add-apt-repository -y $APPLICATION_PPA
    package_update
    package_install "$APPLICATION_ID"
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
