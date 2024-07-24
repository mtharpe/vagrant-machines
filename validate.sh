#!/bin/bash

export RH_SUBSCRIPTION_MANAGER_USER=""
export RH_SUBSCRIPTION_MANAGER_PW=""
export PROVIDER="virtualbox"

for f in `ls -d */`;
do
    cd "$f" && echo Validating $f && vagrant validate --provider=$PROVIDER
    cd ..
done;
