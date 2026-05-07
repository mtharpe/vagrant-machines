[![CircleCI](https://dl.circleci.com/status-badge/img/gh/mtharpe/vagrant-machines/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/mtharpe/vagrant-machines/tree/main)

# vagrant-machines

One-command Vagrant VMs that work the same on macOS and Linux. The host
platform picks a sensible Vagrant provider; you pick an OS from a short
catalog (`boxes.yaml`) and the rest is wired up automatically — including
the right Ansible playbook for the OS family.

## Layout

```
.
├── Makefile             Thin entry point. All targets call into bin/.
├── bin/
│   ├── doctor           Check prereqs and print install hints
│   ├── install-boxes    Install every box in boxes.yaml for your provider
│   └── new-machine      Create a new VM dir from template/
├── boxes.yaml           OS catalog (single source of truth for box names)
├── template/            Per-VM scaffold (Vagrantfile + Makefile)
├── provisioners/ansible Reusable Ansible playbooks (ubuntu / centos / fedora)
└── .machines/           Where created VMs live (gitignored)
```

## Usage

```sh
make doctor                         # check prereqs for your platform
make setup                          # install the right provider + plugin for your host
make install                        # install default boxes for your provider

make new                            # interactive: pick OS, name, role
make new name=web1 os=ubuntu24 role=server

make up name=web1                   # start
make ssh name=web1
make halt name=web1
make destroy name=web1
make list                           # show every machine under .machines/
```

Override the auto-detected provider:

```sh
make new name=db1 os=rocky10 provider=virtualbox
VAGRANT_DEFAULT_PROVIDER=libvirt make install
```

## Provider defaults

| Host                | Default provider  | Notes                                                |
|---------------------|-------------------|------------------------------------------------------|
| Apple Silicon (Mac) | `vmware_desktop`  | VMware Fusion (free for personal use; manual install)|
| Intel Mac           | `virtualbox`      |                                                      |
| Linux (libvirtd)    | `libvirt`         | Auto-detected via `virsh`.                           |
| Linux (no libvirt)  | `virtualbox`      |                                                      |

**Apple Silicon notes:** Bento publishes the same box image for
`vmware_desktop`, `parallels`, and `virtualbox` on both arm64 and amd64.
Fusion 13+ is the recommended free path because it can stably emulate x86_64
on Apple Silicon; UTM was tried and removed because UTM.app crashes when
emulating amd64. Fusion's installer must be downloaded manually from
[Broadcom Support](https://support.broadcom.com) (the Homebrew cask was
disabled in 2025-06 because the download requires authentication). Parallels
is a paid alternative installable via `brew install --cask parallels`.

## Tab completion

The repo ships completion scripts under `completions/` that complete:
target names (`make up<TAB>`), VM names (`name=<TAB>` lists `.machines/*`),
OS ids (`os=<TAB>` reads `boxes.yaml`), and roles/providers/archs.

```sh
# fish
echo "source $PWD/completions/vagrant-machines.fish" >> ~/.config/fish/config.fish

# bash
echo "source $PWD/completions/vagrant-machines.bash" >> ~/.bashrc
```

The completions only kick in when `make` is invoked from within this repo
tree, so they don't interfere with `make` in other projects.

## Adding an OS

Edit `boxes.yaml`:

```yaml
debian12:
  family: apt
  ansible: ubuntu          # closest matching playbook dir under provisioners/ansible
  boxes:
    virtualbox: bento/debian-12
    libvirt:    generic/debian12
    qemu:                  # leave blank if no qemu box yet
```

Then `make new name=foo os=debian12`. No code changes required.

## Migrating from the old layout

The old per-platform split, the giant inline `vm:` Make target, and the
top-level `template-vm/` are gone. Existing VMs you've already created under
`.machines/` keep their own Vagrantfile and aren't touched — they continue to
work via `cd .machines/<name> && vagrant up`.
