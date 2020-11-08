#!/bin/bash

sudo DEBIAN_FRONTEND=noninteractive apt-get install apache2 mysql-client -y
sudo touch /etc/consul.d/consul.json
sudo chmod -R 640 /etc/consul.d
sudo systemctl enable consul
sudo systemctl enable consul-web-proxy
sudo systemctl start consul || true
sudo systemctl start consul-web-proxy