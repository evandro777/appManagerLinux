#JAVA > THIRD-PARTY PPA > ORACLE - REQUIRED BY SOME BANKS
sudo add-apt-repository -y ppa:webupd8team/java

#JAVA
sudo apt install -y default-jre

#JAVA > ORACLE - REQUIRED BY SOME BANKS
#AUTO SET YES TO LICENSE AGREEMENT
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt install -y oracle-java8-installer

