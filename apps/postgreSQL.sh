#!/bin/bash

sudo apt install -y wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

#DYNAMIC > ONLY FOR UBUNTU
#sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'

#UBUNTU 18 (Linux Mint 19)
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'

sudo apt update
sudo apt install -y postgresql postgresql-contrib


#SET A PASSWORD
echo "Set a password for postgres user"
sudo -u postgres psql postgres --command="\password postgres"

echo ""
echo 'Edit the file "/etc/postgresql/12/main/pg_hba.conf" the location may vary, depending on version'
echo ""
echo "Scroll down to the line that describes local socket connections. It may look like this:"
echo ""
echo "local   all             all                                      peer"
echo ""
echo 'Change to "peer" to "md5"'

echo ""
echo ""
read -p "Pressione [Enter] para continuar."

#Allow remote connections
sudo xed /etc/postgresql/12/main/pg_hba.conf

sudo service postgresql restart