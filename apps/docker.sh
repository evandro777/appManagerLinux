#packages which let apt use packages over HTTPS:
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

#Third party - Official Docker Repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" | sudo tee -a /etc/apt/sources.list.d/docker.list
sudo apt update
apt-cache policy docker-ce
sudo apt install -y docker-ce docker-ce-cli containerd.io

#execute docker without sudo
sudo usermod -aG docker ${USER}
su - ${USER}

echo "Downloading and installing docker-composer"
latestDockerComposeVersion="$(curl -sL https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')"
kernelName="$(uname -s | awk '{print tolower($0)}')"
machineHardwareName="$(uname -m)"
dockerComposeUrlDownload="https://github.com/docker/compose/releases/download/$latestDockerComposeVersion/docker-compose-$kernelName-$machineHardwareName"

echo "Latest docker-composer version found: $latestDockerComposeVersion"

sudo curl -L "$dockerComposeUrlDownload" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo docker-compose --version
