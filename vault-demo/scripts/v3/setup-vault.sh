#!/bin/bash

echo "Setting Vault Systemd to start at boot ..."
sudo systemctl enable vault.service
sudo systemctl start vault.service
sudo systemctl enable consul.service
sudo systemctl start consul.service
sleep 30

# INIT_RESPONSE=$(VAULT_ADDR=http://172.20.20.12:8200 vault operator init -format=json -key-shares 1 -key-threshold 1)
# UNSEAL_KEY=$(echo "$INIT_RESPONSE" | jq -r .unseal_keys_b64[0])
# VAULT_TOKEN=$(echo "$INIT_RESPONSE" | jq -r .root_token)

# echo "$UNSEAL_KEY" > vault.info
# echo "$VAULT_TOKEN" >> vault.info

# export VAULT_ADDR=http://172.20.20.12:8200

# vault operator unseal "$UNSEAL_KEY"

# sleep 10

# vault login "$VAULT_TOKEN"