![Vagrant Validation](https://github.com/mtharpe/vagrant-machines/workflows/Vagrant%20Validation/badge.svg)


# The Vagrant Machines Repo

Vagrant is a tool for building and managing virtual machine environments in a single workflow. With an easy-to-use workflow and focus on automation, Vagrant lowers development environment setup time, increases production parity, and makes the "works on my machine" excuse a relic of the past.

## Installing

You will need to install some things before you can use the Vagrant machines in this repo. The software can be installed via package manager or standalone installs, but must be functional before these will work.

- Vagrant
- VirtualBox

Next, you can use the `Makefile` included in the repo to install, update, validate, and prune the machines.

All boxes are derived from https://roboxes.org/ and have a prefix of ```generic``` based on the names, and so when you are creating new Vm's it is assumed that you are using this repo for the creation.

Example:

```
make plugins
make install
make update
make validate
make clean
make vm name=<mahine-name> box=<somebox>
```

## Examples

```
$ make vm name=centos-7 box=centos7
$ cd centos-7
$ vagrant up
```

After running the above two commands, you will have a fully running virtual machine in VirtualBox running the latest CentOS 7 64-bit version.

You can SSH into this machine with `vagrant ssh`, and when you are done playing around, you can terminate the virtual machine with `vagrant destroy`.
