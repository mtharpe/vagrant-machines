![Vagrant Validation](https://github.com/mtharpe/vagrant-machines/workflows/Vagrant%20Validation/badge.svg)

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

| Host                | Default provider | Notes                                              |
|---------------------|------------------|----------------------------------------------------|
| Apple Silicon (Mac) | `qemu`           | Sparse box ecosystem; see note below.              |
| Intel Mac           | `virtualbox`     |                                                    |
| Linux (libvirtd)    | `libvirt`        | Auto-detected via `virsh`.                         |
| Linux (no libvirt)  | `virtualbox`     |                                                    |

**Apple Silicon caveat:** `vagrant-qemu` works, but most Vagrant publishers
either don't ship qemu boxes or mislabel libvirt boxes as qemu. The catalog
ships with `qemu:` entries blank — fill them in once you find or build a
working box for each OS. Alternatives if qemu doesn't pan out: `parallels`
(paid) or `utm` via the `vagrant_utm` plugin.

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
