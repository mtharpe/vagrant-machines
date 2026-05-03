#!/bin/bash

export RH_SUBSCRIPTION_MANAGER_USER=""
export RH_SUBSCRIPTION_MANAGER_PW=""
export PROVIDER="qemu"

vm_root="${VM_ROOT:-.machines}"

for f in ./template-vm "./$vm_root"/*/; do
    [ -d "$f" ] && [ -f "$f/Vagrantfile" ] || continue
    ( cd "$f" && echo "Validating $f" && vagrant validate -p )
done
