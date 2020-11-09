#!/bin/bash

echo "Setting Vault Systemd to start at boot ..."
sudo systemctl enable vault.service
sudo systemctl start vault.service
sudo systemctl enable consul.service
sudo systemctl start consul.service
sleep 15