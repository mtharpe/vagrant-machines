#!/bin/bash

vagrant up 

vagrant ssh v1 -c './init-vault.sh'

UNSEAL_KEY=`vagrant ssh v1 -c "cat unseal.key"`
VAULT_TOKEN=`vagrant ssh v1 -c "cat token.key"`


vagrant ssh v1 -c "VAULT_ADDR=http://172.20.20.10:8200 vault operator unseal ${UNSEAL_KEY}"
vagrant ssh v1 -c "VAULT_ADDR=http://172.20.20.10:8200 vault login ${VAULT_TOKEN}"

vagrant ssh v2 -c "VAULT_ADDR=http://172.20.20.11:8200 vault operator unseal ${UNSEAL_KEY}"
vagrant ssh v2 -c "VAULT_ADDR=http://172.20.20.11:8200 vault login ${VAULT_TOKEN}"

vagrant ssh v3 -c "VAULT_ADDR=http://172.20.20.12:8200 vault operator unseal ${UNSEAL_KEY}"
vagrant ssh v3 -c "VAULT_ADDR=http://172.20.20.12:8200 vault login ${VAULT_TOKEN}"