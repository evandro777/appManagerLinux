#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Spotify - Official PPA${NC}"

curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/spotify.gpg
echo "deb [signed-by=/etc/apt/keyrings/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

sudo apt-get install -y spotify-client
