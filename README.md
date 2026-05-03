![Vagrant Validation](https://github.com/mtharpe/vagrant-machines/workflows/Vagrant%20Validation/badge.svg)


# The Vagrant Machines Repo

Cross-platform Vagrant environments. Clone the repo on either host and use the
matching subdirectory:

- [`mac/`](./mac) — Apple Silicon (M-series) using **QEMU** via the
  [`vagrant-qemu`](https://github.com/ppggff/vagrant-qemu) plugin.
  - Native `aarch64` guests use Hypervisor.framework (`hvf`) acceleration.
  - `x86_64` guests run under QEMU TCG emulation (slower, but works for
    testing x86 code).
- [`linux/`](./linux) — x86_64 Linux using **VirtualBox**, **libvirt**, or
  **VMware Desktop**.

Ansible provisioners are shared at the top level under
[`provisioners/ansible/`](./provisioners/ansible) so both platforms use the
same playbooks.

## Layout

```
vagrant-machines/
├── Makefile          # top-level dispatcher (auto-detects platform)
├── mac/              # qemu (aarch64 + x86_64 emulation)
│   ├── Makefile
│   ├── template-vm/
│   └── validate.sh
├── linux/            # virtualbox / libvirt / vmware
│   ├── Makefile
│   ├── template-vm/
│   └── validate.sh
└── provisioners/
    └── ansible/      # shared by both platforms
```

VMs are created under `<platform>/.machines/<vm-name>/` (gitignored).

## Quick start

The top-level `Makefile` auto-detects the platform from `uname -s`:

```
make plugins        # install platform-appropriate plugin(s)
make install        # install the platform's default boxes
make check          # verify required CLIs / plugins
make vm             # interactive VM creation
make validate       # validate Vagrantfiles
make clean          # prune unused boxes
```

Force a platform:

```
make PLATFORM=mac install
make PLATFORM=linux install
```

Or work in a platform directory directly:

```
cd mac    # or: cd linux
make help
make install
make vm name=ubuntu-test box=gyptazy/ubuntu24.04-amd64 role=server family=apt
cd .machines/ubuntu-test
vagrant up
```

## Mac (M-series) prerequisites

```
brew install --cask vagrant
brew install qemu
make -C mac plugins      # installs vagrant-qemu
```

Default boxes (override with `BOXES='...'`):

- `perk/ubuntu-2204-arm64` — native arm64
- `gyptazy/ubuntu24.04-arm64` — native arm64
- `gyptazy/ubuntu24.04-amd64` — x86_64 (TCG emulation)
- `gyptazy/rocky9-amd64` — x86_64 (TCG emulation)

Find more qemu-providered boxes at
<https://app.vagrantup.com/boxes/search?provider=qemu>.

The mac template auto-detects guest arch from the box name: anything matching
`arm64`/`aarch64` gets `qemu.arch = aarch64`, otherwise `x86_64`. Override with
`QEMU_ARCH=...`, `QEMU_CPUS=...`, `QEMU_MEMORY=...` env vars.

Networking on `vagrant-qemu` uses user-mode (SLIRP); SSH is forwarded to a
host port automatically by Vagrant. Set `SSH_HOST_PORT=2222` to pin it.

## Linux (x86_64) prerequisites

Install Vagrant and at least one of:

- VirtualBox (default)
- libvirt + qemu/kvm
- VMware Workstation/Desktop

```
make -C linux plugins   # vagrant-clean vagrant-hostmanager vagrant-auto_network vagrant-cachier vagrant-vbguest vagrant-scp
```

## Creating a VM

The `vm` target supports both interactive and non-interactive use.

### Interactive

```
make vm
```

Prompts for VM name, box, role (`server`/`workstation`), and package family
(`apt`/`rpm`) when it cannot be inferred from the box name. On Linux it also
prompts for the provider when the box has multiple installed.

### Non-interactive

```
make vm name=<machine-name> box=<installed-box-name> role=<server|workstation> family=<apt|rpm>
```

Optional overrides:

```
make vm name=<machine-name> box=<installed-box-name> role=server family=apt \
        playbook=<ansible-*-base> \
        provider=<virtualbox|libvirt|vmware_desktop>   # linux only
```

`make vm` rewrites the generated `Vagrantfile` to set the box, ansible
playbook/role/setup, and (on linux) the provider, then validates the playbook
path under `provisioners/ansible/`.

VMs are created under `<platform>/.machines/<vm-name>/` (gitignored).

## Examples

```
# On a Mac (M5)
make vm name=rocky-arm box=gyptazy/rocky9-arm64 role=server family=rpm
make vm name=ubuntu-x86 box=gyptazy/ubuntu24.04-amd64 role=server family=apt
cd mac/.machines/ubuntu-x86
vagrant up
vagrant ssh

# On x86_64 Linux
make vm name=rocky-server box=bento/rockylinux-9 role=server family=rpm
make vm name=ubuntu-workstation box=bento/ubuntu-24.04 role=workstation family=apt
cd linux/.machines/rocky-server
vagrant up
```
