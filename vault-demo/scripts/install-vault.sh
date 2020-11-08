#!/bin/bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

echo "Installing dependencies with apt..."
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --auto-remove
DEBIAN_FRONTEND=noninteractive apt-get install -y --auto-remove vault jq

echo "Creating Vault directories ..."
if [ ! -d /etc/vault.d ]; then
    sudo mkdir /etc/vault.d
fi

sudo chmod a+w /etc/vault.d

if [ ! -d /opt/vault ]; then
    sudo mkdir /opt/vault
fi