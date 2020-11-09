#!/bin/bash

vagrant up 

vagrant ssh v1 -c './init-vault.sh' >/dev/null 2>/dev/null

UNSEAL_KEY=`vagrant ssh v1 -c "cat unseal.key"`
VAULT_TOKEN=`vagrant ssh v1 -c "cat token.key"`


vagrant ssh v1 -c "VAULT_ADDR=http://172.20.20.10:8200 vault operator unseal ${UNSEAL_KEY}" >/dev/null 2>/dev/null
vagrant ssh v1 -c "VAULT_ADDR=http://172.20.20.10:8200 vault login ${VAULT_TOKEN}" >/dev/null 2>/dev/null

vagrant ssh v2 -c "VAULT_ADDR=http://172.20.20.11:8200 vault operator unseal ${UNSEAL_KEY}" >/dev/null 2>/dev/null
vagrant ssh v2 -c "VAULT_ADDR=http://172.20.20.11:8200 vault login ${VAULT_TOKEN}" >/dev/null 2>/dev/null

vagrant ssh v3 -c "VAULT_ADDR=http://172.20.20.12:8200 vault operator unseal ${UNSEAL_KEY}" >/dev/null 2>/dev/null
vagrant ssh v3 -c "VAULT_ADDR=http://172.20.20.12:8200 vault login ${VAULT_TOKEN}" >/dev/null 2>/dev/null

echo -e "\n"
echo -e "
██╗   ██╗ █████╗ ██╗   ██╗██╗  ████████╗    ██╗███╗   ██╗███████╗ ██████╗ 
██║   ██║██╔══██╗██║   ██║██║  ╚══██╔══╝    ██║████╗  ██║██╔════╝██╔═══██╗
██║   ██║███████║██║   ██║██║     ██║       ██║██╔██╗ ██║█████╗  ██║   ██║
╚██╗ ██╔╝██╔══██║██║   ██║██║     ██║       ██║██║╚██╗██║██╔══╝  ██║   ██║
 ╚████╔╝ ██║  ██║╚██████╔╝███████╗██║       ██║██║ ╚████║██║     ╚██████╔╝
  ╚═══╝  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝       ╚═╝╚═╝  ╚═══╝╚═╝      ╚═════╝ 
"
echo -e "                                          
          *********************************************
            Vault Token: ${VAULT_TOKEN}
          |-------------------------------------------|
          | Servers:                                  |
          | v1:8200 - Primary Vault                   |
          | v1:8500 - Primary Consul                  |
          | v2:8200 - Secondary Vault                 |
          | v2:8500 - Secrondar Consul                |
          | v3:8200 - Secondary Vault                 |
          |v3:8500 - Secrondar Consul                 |  
          *********************************************
\n"
