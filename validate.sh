#!/bin/bash

for f in *centos* *fedora* *redhat* *ubuntu* ;
do
    cd "$f" && echo Validating "$f" && vagrant validate
    cd ..
done;