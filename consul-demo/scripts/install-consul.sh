#!/bin/bash

CONSUL_DEMO_VERSION='1.8.5'

echo "Installing dependencies ..."
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq --auto-remove
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq unzip curl jq dnsutils iptables-persistent netfilter-persistent

echo "Fetching Consul version ${CONSUL_DEMO_VERSION} ..."
cd /tmp/
curl -s https://releases.hashicorp.com/consul/${CONSUL_DEMO_VERSION}/consul_${CONSUL_DEMO_VERSION}_linux_amd64.zip -o consul.zip

echo "Installing Consul version ${CONSUL_DEMO_VERSION} ..."
unzip consul.zip
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul

sudo mkdir /etc/consul.d
sudo chmod a+w /etc/consul.d

sudo iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
sudo iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
sudo iptables-save  > /etc/iptables/rules.v4
sudo ip6tables-save > /etc/iptables/rules.v6

sudo iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
sudo iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
sudo netfilter-persistent save

sudo sh -c "echo '172.20.20.10 n1
172.20.20.11 n2
172.20.20.12 n3' >> /etc/hosts"