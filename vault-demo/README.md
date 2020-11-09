# Vault Demo

## Running this demo

This is a functional OSS version of Vault backed by Consul. There are a total of three nodes, and the process is fully automated. The process runs as follows:

1. Vagrant UP
2. Vagrant SSH to V1 for initial init
3. Set UNSEAL_KEY via V1 using Vagrant SSH
4. Set VAULT_TOKEN via V1 using Vagrant SSH
5. Vagrant SSH to V1 to get the unseal info
6. Vagrant SSH to V1 to get the Vault token info
7. Vagrant SSH to V2 to get the unseal info
8. Vagrant SSH to V2 to get the Vault token info
9. Vagrant SSH to V3 to get the unseal info
10. Vagrant SSH to V3 to get the Vault token info

<br>

### Nodes Details

| Node  |   IP Address    | FQDN  |
| :---: | :-------------: | :---: |
|  V1   | 172\.20\.20\.10 |  v1   |
|  V2   | 172\.20\.20\.11 |  v2   |
|  V3   | 172\.20\.20\.12 |  v3   |
|       |                 |       |

<br>

<br>

### Nodes and Ports

| Node  | Vault Port | Consul Port |
| :---: | :--------: | :---------: |
|  V1   |    8200    |    8500     |
|  V2   |    8200    |    8500     |
|  V3   |    8200    |    8500     |
|       |            |             |

<br>
<br>

**Note:** You will need to have a few plugins for Vagrant to make this work, so please see the root README.md file for details