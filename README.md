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
| Apple Silicon (Mac) | `utm`            | Free; UTM uses Apple Virtualization.framework.     |
| Intel Mac           | `virtualbox`     |                                                    |
| Linux (libvirtd)    | `libvirt`        | Auto-detected via `virsh`.                         |
| Linux (no libvirt)  | `virtualbox`     |                                                    |

**Apple Silicon notes:** `make setup` will install UTM and the `vagrant_utm`
plugin. The catalog uses Bento boxes (`bento/ubuntu-22.04`, `bento/rockylinux-10.0`,
etc.), which Bento publishes natively for arm64 across `utm`, `parallels`,
`virtualbox`, and `vmware_desktop`. The `qemu:` entries are intentionally blank
because the public qemu/arm64 box ecosystem is broken (publishers ship libvirt
payloads under a qemu label).

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
