#LIBREOFFICE > OFFICIAL
#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color
echo -e "${ORANGE}Installing Libreoffice${NC}"

sudo add-apt-repository -y ppa:libreoffice/ppa

#Libreoffice > icons
#sudo apt install -y libreoffice-style-elementary

sudo apt install -y libreoffice
