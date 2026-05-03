# Fish completion for the top-level Makefile in this repo.
# Source from ~/.config/fish/config.fish (or symlink to ~/.config/fish/conf.d/):
#   source /path/to/vagrant-machines/completions/vagrant-machines.fish
# Hooks `make` only when the cwd is inside the repo (detected via boxes.yaml +
# bin/ + Makefile in the cwd ancestry), so other `make` invocations are
# untouched.

function __vagrant_machines_root
    set -l dir $PWD
    while test "$dir" != /
        if test -f "$dir/Makefile" -a -f "$dir/boxes.yaml" -a -d "$dir/bin"
            echo $dir
            return 0
        end
        set dir (dirname $dir)
    end
    return 1
end

function __vagrant_machines_in_repo
    __vagrant_machines_root >/dev/null
end

function __vagrant_machines_machines
    set -l root (__vagrant_machines_root); or return
    set -l vm_root .machines
    test -n "$VM_ROOT"; and set vm_root $VM_ROOT
    test -d "$root/$vm_root"; and ls -1 "$root/$vm_root" 2>/dev/null
end

function __vagrant_machines_os_ids
    set -l root (__vagrant_machines_root); or return
    python3 -c "import yaml; print('\n'.join(yaml.safe_load(open('$root/boxes.yaml'))))" 2>/dev/null
end

# Targets
complete -c make -n '__vagrant_machines_in_repo' -f -a 'help doctor setup install new up halt destroy ssh provision status list clean'

# k=v args
complete -c make -n '__vagrant_machines_in_repo' -f -a '(__vagrant_machines_machines | string replace -r "^" "name=")'   -d 'VM under .machines/'
complete -c make -n '__vagrant_machines_in_repo' -f -a '(__vagrant_machines_os_ids   | string replace -r "^" "os=")'     -d 'OS id from boxes.yaml'
complete -c make -n '__vagrant_machines_in_repo' -f -a 'role=server role=workstation' -d 'VM role'
complete -c make -n '__vagrant_machines_in_repo' -f -a 'provider=vmware_desktop provider=parallels provider=virtualbox provider=libvirt' -d 'Vagrant provider'
complete -c make -n '__vagrant_machines_in_repo' -f -a 'arch=amd64 arch=arm64' -d 'Box architecture'
