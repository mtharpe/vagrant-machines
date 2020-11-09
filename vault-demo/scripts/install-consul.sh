#!/bin/bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

echo "Installing dependencies with apt..."
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --auto-remove
DEBIAN_FRONTEND=noninteractive apt-get install -y --auto-remove consul

echo "Creating Consul directories ..."
if [ ! -d /etc/consul.d ]; then
    sudo mkdir -p /etc/consul.d
    sudo chmod a+w /etc/vault.d
fi

if [ ! -d /var/consul/data ]; then
    sudo mkdir -p /var/consul/data
    sudo chmod -R a+w /var/consul
fi