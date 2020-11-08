#!/bin/bash

cp -r template-vm $1
sed -i "s/template-vm/${1}/g" $1/Vagrantfile