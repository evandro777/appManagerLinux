#OSQUERY > OFFICIAL

sudo mkdir -p /etc/apt/keyrings
curl -L https://pkg.osquery.io/deb/pubkey.gpg | sudo tee /etc/apt/keyrings/osquery.asc
sudo add-apt-repository 'deb [arch=amd64 signed-by=/etc/apt/keyrings/osquery.asc] https://pkg.osquery.io/deb deb main'

sudo apt-get install -y osquery
