#Steam Ubuntu Official
#COLORS
ORANGE='\033[0;33m'
NC='\033[0m' # No Color / Reset color
echo -e "${ORANGE}Installing Steam${NC}"

sudo apt install -y steam-installer
steam

read -p "Press [Enter] to continue."
