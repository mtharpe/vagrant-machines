#!/bin/bash

for i in web1 web2 db; do vagrant destroy -f $i; done
for i in web1 web2 db; do vagrant up $i; done
