#!/bin/bash

readonly APPLICATION_NAME="Conky & Seven Conky (+autostart): Conky with clock, disk, network, process, weather, music [official GitHub]"
readonly APPLICATION_LOCATION="${HOME}/.conky/seven-conky/"

function perform_install() {
    # Access the associative array passed as a parameter
    local -n params=$1

    install_location="${APPLICATION_LOCATION}" \
        auto_start="y" \
        weather_key="${params[weather\-key]}" \
        weather_city_id="${params[weather\-city\-id]}" \
        weather_unit="${params[weather\-unit]}" \
        weather_language="${params[weather\-language]}" \
        bash <(curl -s https://raw.githubusercontent.com/evandro777/seven-conky/main/install.sh)

    sudo apt-get install -y -q conky conky-all
    sudo apt-get install -y -q fonts-font-awesome
    #allow regular user to execute hddtemp without needing sudo (to get temperatures for conky)
    sudo chmod +s /usr/sbin/hddtemp
}

function perform_uninstall() {
    rm -rf "${APPLICATION_LOCATION}"
}

function perform_check() {
    if [ -z "$(ls -A "${APPLICATION_LOCATION}" 2> /dev/null)" ]; then
        echo 0 # not installed
    else
        echo 1 # is installed
    fi
}

function get_parameters() {
    # Don't use echo before read, it's not going to work to set into a variable "app-menu-init.sh"
    read -rp $'Units [metric (or empty): Celsius, standard: Kelvin, imperial: Fahrenheit]?: \n' weather_unit
    if [ -z "$weather_unit" ]; then
        weather_unit="metric"
    fi

    read -rp $'Language [en (or empty): English, pt_br: Português Brasil, sp | es: Spanish] (get a complete list at: https://openweathermap.org/current#multi)?: \n' weather_language
    if [ -z "$weather_language" ]; then
        weather_language="en"
    fi

    # Prompt for weather key if not provided
    while [ -z "$weather_key" ]; do
        read -rp $'Open Weather Map API Key (To get one, register an account and create an api key on https://home.openweathermap.org/api_keys)?: \n' weather_key
    done

    # Prompt for weather city id if not provided
    while [ -z "$weather_city_id" ]; do
        read -rp $'Open Weather City Id:\nTo get the city id to get the weather, search your city id at: [https://openweathermap.org/], then copy the link of the city, something like: https://openweathermap.org/city/3457095 and use only the end number?: \n' weather_city_id
    done

    echo "--weather-key=$weather_key --weather-city-id=$weather_city_id --weather-unit=$weather_unit --weather-language=$weather_language"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
