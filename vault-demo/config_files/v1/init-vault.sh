#!/bin/bash

INIT_RESPONSE=$(VAULT_ADDR=http://172.20.20.10:8200 vault operator init -format=json -key-shares 1 -key-threshold 1)

UNSEAL_KEY=$(echo "$INIT_RESPONSE" | jq -r .unseal_keys_b64[0])
VAULT_TOKEN=$(echo "$INIT_RESPONSE" | jq -r .root_token)

echo "$UNSEAL_KEY" >> unseal.key
echo "$VAULT_TOKEN" >> token.key

export VAULT_ADDR=http://172.20.20.10:8200

vault operator unseal "$UNSEAL_KEY"