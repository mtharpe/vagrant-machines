#!/bin/bash

echo "Installing dependencies with apt..."
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --auto-remove
DEBIAN_FRONTEND=noninteractive apt-get install -y --auto-remove vault jq

sudo setcap cap_ipc_lock=+ep $(readlink -f $(which vault))

echo "Creating Vault directories ..."
if [ ! -d /etc/vault.d ]; then
    sudo mkdir -p /etc/vault.d
    sudo chmod a+w /etc/vault.d
fi

if [ ! -d /var/vault/data ]; then
    sudo mkdir -p /var/vault/data
    sudo chmod -R a+w /var/vault
fi