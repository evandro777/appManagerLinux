#Insync > Official Repository:
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ACCAF35C
#echo deb http://apt.insynchq.com/ubuntu xenial non-free contrib | sudo tee /etc/apt/sources.list.d/insync.list
echo deb http://apt.insynchq.com/mint serena non-free contrib | sudo tee /etc/apt/sources.list.d/insync.list
sudo apt update && sudo apt install -y insync

read -p "Press [Enter] to continue."
