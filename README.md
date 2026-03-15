![Vagrant Validation](https://github.com/mtharpe/vagrant-machines/workflows/Vagrant%20Validation/badge.svg)


# The Vagrant Machines Repo

Vagrant is a tool for building and managing virtual machine environments in a single workflow. With an easy-to-use workflow and focus on automation, Vagrant lowers development environment setup time, increases production parity, and makes the "works on my machine" excuse a relic of the past.

## Installing

You will need to install some things before you can use the Vagrant machines in this repo. The software can be installed via package manager or standalone installs, but must be functional before these will work.

- Vagrant
- VirtualBox

Next, you can use the `Makefile` included in the repo to install, update, validate, and prune the machines.

Boxes can come from any publisher namespace (for example `bento/*`, `generic/*`, `gnome-shell-box/*`).

Example:

```
make plugins
make install
make update
make validate
make clean
make vm
```

## Creating a VM

The `vm` target supports both interactive and non-interactive use.

### Interactive

Run `make vm` and provide prompted values:

- VM name
- Installed Vagrant box
- Provider (`virtualbox`, `libvirt`, or `vmware_desktop`)
- Role (`server` or `workstation`)
- Package family (`apt` or `rpm`) when it cannot be inferred from the box name

If the selected box already exists locally for a specific provider, `make vm` will auto-select that provider (or prompt from installed providers) to avoid provider mismatch errors.

### Non-interactive

You can provide variables directly:

```
make vm name=<machine-name> box=<installed-box-name> role=<server|workstation> family=<apt|rpm>
```

Optional override:

```
make vm name=<machine-name> box=<installed-box-name> role=<server|workstation> family=<apt|rpm> playbook=<ansible-*-base> provider=<virtualbox|libvirt|vmware_desktop>
```

By default, `vm` rewrites the generated `Vagrantfile` to set:

- `config.vm.box`
- `ANSIBLE_PLAYBOOK`
- `ANSIBLE_ROLE`
- `ANSIBLE_SETUP_FILE`
- `VAGRANT_PROVIDER`

and validates that the selected playbook path exists under `provisioners/ansible`.

If you choose a provider that is not installed for the selected box, `make vm` now fails early with a suggested `make box-add ...` command.

Generated VMs are created under `./.machines/<machine-name>` by default. This directory is ignored by Git so personal/local machine definitions are not committed.

You can view or override this location:

```
make vm-root
make vm vm_root=.machines-lab name=<machine-name> box=<installed-box-name> role=<server|workstation> family=<apt|rpm>
```

### Migration note (existing root-level VMs)

If you created VM directories at the repository root before this change, move them into `.machines/`.

One at a time with Make:

```
make vm-migrate name=<machine-name>
```

Example (replace names with your VM directories):

```
mkdir -p .machines
mv my-old-vm another-old-vm .machines/
```

Then run Vagrant from the new location:

```
cd .machines/my-old-vm
vagrant status
```

## Examples

```
$ make vm
# prompts for name/box/role/family

$ make vm name=rocky-server box=bento/rockylinux-9 role=server family=rpm
$ make vm name=ubuntu-workstation box=bento/ubuntu-24.04 role=workstation family=apt

$ cd .machines/rocky-server
$ vagrant up

$ cd .machines/ubuntu-workstation
$ vagrant up
```

After running the commands above, you will have a fully running virtual machine in VirtualBox.

You can SSH into this machine with `vagrant ssh`, and when you are done playing around, you can terminate the virtual machine with `vagrant destroy`.
