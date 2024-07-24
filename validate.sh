#!/bin/bash

export RH_SUBSCRIPTION_MANAGER_USER=""
export RH_SUBSCRIPTION_MANAGER_PW=""

for f in `ls -d */`;
do
    cd "$f" && echo Validating $f && vagrant validate
    cd ..
done;
