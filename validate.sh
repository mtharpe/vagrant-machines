#!/bin/bash

for f in `ls -d */`;
do
    cd "$f" && echo Validating $f && vagrant validate
    cd ..
done;