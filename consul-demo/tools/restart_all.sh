#!/bin/bash

for i in n1 n2 n3 web1 web2 db; do echo -e  "Rebooting ${i} \n" && vagrant ssh -c 'sudo reboot now' $i; done
