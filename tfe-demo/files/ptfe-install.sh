#!/bin/bash

curl -o install.sh https://install.terraform.io/ptfe/stable
bash ./install.sh \
no-proxy \
private-address=10,0.0.71 \
public-address=10.0.0.71
