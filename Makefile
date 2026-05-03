# Thin entry point. Real logic lives in bin/.

VM_ROOT ?= .machines

.DEFAULT_GOAL := help

.PHONY: help doctor setup install new up halt destroy ssh provision status list clean

help:
	@echo "Vagrant machines — works the same on Mac (qemu) and Linux (libvirt/virtualbox)."
	@echo
	@echo "Setup:"
	@echo "  make doctor                Check prereqs for your platform"
	@echo "  make setup                 Install Vagrant provider + plugin for your platform"
	@echo "  make install               Install all default boxes for your provider"
	@echo
	@echo "Create / control machines:"
	@echo "  make new                   Interactive: pick OS, name, role"
	@echo "  make new name=web1 os=ubuntu24 role=server"
	@echo "  make up name=web1          (cd $(VM_ROOT)/web1 && vagrant up)"
	@echo "  make ssh name=web1"
	@echo "  make halt name=web1"
	@echo "  make destroy name=web1"
	@echo "  make status name=web1"
	@echo "  make list                  Show all machines under $(VM_ROOT)/"
	@echo
	@echo "Override provider:   make new name=db1 os=rocky10 provider=virtualbox"
	@echo "Override VM root:    make ... VM_ROOT=.machines-lab"

doctor:
	@bin/doctor

setup:
	@bin/install-provider

install:
	@bin/install-boxes

new:
	@bin/new-machine \
		$(if $(name),name=$(name)) \
		$(if $(os),os=$(os)) \
		$(if $(role),role=$(role)) \
		$(if $(provider),provider=$(provider)) \
		vm_root=$(VM_ROOT)

# Per-VM dispatch. `name=...` is required.
up halt destroy ssh provision status:
	@test -n "$(name)" || { echo "name=<vm> is required"; exit 1; }
	@test -d "$(VM_ROOT)/$(name)" || { echo "no such VM: $(VM_ROOT)/$(name)"; exit 1; }
	@$(MAKE) -C "$(VM_ROOT)/$(name)" $@

list:
	@if [ -d "$(VM_ROOT)" ]; then \
		ls -1 "$(VM_ROOT)" 2>/dev/null | sed 's/^/  /'; \
	else \
		echo "(no machines yet — run 'make new')"; \
	fi

clean:
	@vagrant box prune
