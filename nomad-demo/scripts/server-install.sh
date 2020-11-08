#!/bin/bash

sudo systemctl enable consul.service
sudo systemctl enable nomad.service
sudo systemctl start consul.service
sudo systemctl start nomad.service