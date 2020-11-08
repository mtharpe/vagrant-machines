#!/bin/bash

sudo DEBIAN_FRONTEND=noninteractive apt-get install mysql-server -y
sudo touch /etc/consul.d/consul.json
sudo chmod -R 640 /etc/consul.d
sudo systemctl enable consul
sudo systemctl enable consul-db-proxy
sudo systemctl start consul || true
sudo systemctl start consul-db-proxy
sudo mysql -uroot < /tmp/mysql.sql