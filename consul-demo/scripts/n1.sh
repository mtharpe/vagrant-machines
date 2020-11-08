#!/bin/bash

sudo touch /etc/consul.d/consul.hcl
sudo chmod 640 /etc/consul.d/consul.hcl
sudo systemctl enable consul
sudo systemctl start consul || true