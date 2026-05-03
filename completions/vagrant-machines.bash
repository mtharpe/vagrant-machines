# Bash completion for the top-level Makefile in this repo.
# Source it from ~/.bashrc:
#   source /path/to/vagrant-machines/completions/vagrant-machines.bash
# It hooks `make` only when invoked from the repo root (or any subdir of it),
# so it does not pollute completions for unrelated `make` commands.

_vagrant_machines_make_complete() {
  local cur prev words cword
  _init_completion -n = || return

  # Are we inside this repo?
  local root="$PWD"
  while [ "$root" != "/" ]; do
    [ -f "$root/Makefile" ] && [ -f "$root/boxes.yaml" ] && [ -d "$root/bin" ] && break
    root=$(dirname "$root")
  done
  [ "$root" = "/" ] && { _make 2>/dev/null; return; }

  local vm_root="${VM_ROOT:-.machines}"
  local targets="help doctor setup install new up halt destroy ssh provision status list clean"

  # name=<TAB>  -> list machines under VM_ROOT
  if [[ "$cur" == name=* ]]; then
    local list=""
    [ -d "$root/$vm_root" ] && list=$(ls -1 "$root/$vm_root" 2>/dev/null)
    COMPREPLY=( $(compgen -W "$list" -P "name=" -- "${cur#name=}") )
    return
  fi
  # os=<TAB>    -> list os ids from boxes.yaml
  if [[ "$cur" == os=* ]]; then
    local list=""
    list=$(python3 -c "import yaml,sys; print('\n'.join(yaml.safe_load(open('$root/boxes.yaml'))))" 2>/dev/null)
    COMPREPLY=( $(compgen -W "$list" -P "os=" -- "${cur#os=}") )
    return
  fi
  # role=<TAB>
  if [[ "$cur" == role=* ]]; then
    COMPREPLY=( $(compgen -W "server workstation" -P "role=" -- "${cur#role=}") )
    return
  fi
  # provider=<TAB>
  if [[ "$cur" == provider=* ]]; then
    COMPREPLY=( $(compgen -W "vmware_desktop parallels virtualbox libvirt" -P "provider=" -- "${cur#provider=}") )
    return
  fi
  # arch=<TAB>
  if [[ "$cur" == arch=* ]]; then
    COMPREPLY=( $(compgen -W "amd64 arm64" -P "arch=" -- "${cur#arch=}") )
    return
  fi

  # First non-make-flag word -> a target
  COMPREPLY=( $(compgen -W "$targets" -- "$cur") )
}

complete -o nospace -F _vagrant_machines_make_complete make
