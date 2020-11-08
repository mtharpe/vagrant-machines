curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

echo "Installing Docker..."
sudo apt-get update
sudo apt-get upgrade -y --auto-remove
sudo apt-get remove docker docker-engine docker.io
echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common nomad consul -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
stable"
sudo apt-get update
sudo apt-get install -y docker-ce openjdk-8-jdk qemu
sudo service docker restart
sudo usermod -aG docker vagrant
sudo docker --version

# Packages required for nomad & consul
sudo apt-get install unzip curl vim -y

for bin in cfssl cfssl-certinfo cfssljson
do
    echo "Installing $bin..."
    curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
    sudo install /tmp/${bin} /usr/local/bin/${bin}
done

sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d

nomad -autocomplete-install