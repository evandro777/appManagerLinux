#Install Lutris PPA
#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color
echo -e "${ORANGE}Installing Lutris${NC}"

sudo add-apt-repository ppa:lutris-team/lutris
sudo apt update
sudo apt install -y lutris

#NVIDIA
#sudo add-apt-repository ppa:graphics-drivers/ppa
#sudo dpkg --add-architecture i386
#sudo apt update

#sudo apt install -y nvidia-driver-430 libnvidia-gl-430 libnvidia-gl-430:i386

#Install libvulkan
#sudo apt install -y libvulkan1 libvulkan1:i386
