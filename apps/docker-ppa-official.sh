#!/bin/bash

#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color

echo -e "${ORANGE}Installing Docker - Official PPA${NC}"

# Function to get the Ubuntu codename from Linux Mint
get_ubuntu_codename_from_mint() {
    codename=$(cat /etc/upstream-release/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2)
    echo "$codename"
}

# Function to get the Ubuntu codename from Ubuntu
get_ubuntu_codename_from_ubuntu() {
    codename=$(lsb_release -sc)
    echo "$codename"
}

# Function to detect the distribution and get the codename
get_ubuntu_codename() {
    if [ -f /etc/upstream-release/lsb-release ]; then
        # Mint uses /etc/upstream-release/lsb-release
        ubuntu_codename=$(get_ubuntu_codename_from_mint)
    else
        # Ubuntu uses lsb_release -sc
        ubuntu_codename=$(get_ubuntu_codename_from_ubuntu)
    fi

    echo "$ubuntu_codename"
}


# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg


# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$(get_ubuntu_codename)")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo -e "${ORANGE}Docker: execute docker without sudo${NC}"
sudo usermod -aG docker ${USER}
# su - ${USER}


# Removed > docker-compose has been deprecated. Now docker has a plugin for it "docker-compose-plugin", to use: "docker compose" instead of "docker-compose"

#echo "Downloading and installing docker-compose"
#latestDockerComposeVersion="$(curl -sL https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')"
#kernelName="$(uname -s | awk '{print tolower($0)}')"
#machineHardwareName="$(uname -m)"
#dockerComposeUrlDownload="https://github.com/docker/compose/releases/download/$latestDockerComposeVersion/docker-compose-$kernelName-$machineHardwareName"
#
#echo "Latest docker-compose version found: $latestDockerComposeVersion"
#
#sudo curl -L "$dockerComposeUrlDownload" -o /usr/local/bin/docker-compose
#sudo chmod +x /usr/local/bin/docker-compose
#sudo docker-compose --version
