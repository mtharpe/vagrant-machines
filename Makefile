BOXES ?= \
	bento/ubuntu-22.04 \
	bento/ubuntu-24.04 \
	bento/rockylinux-9 \
	bento/rockylinux-10.0 \
	bento/fedora-42
hypervisor = virtualbox
vm_root = .machines
name = 
box = 
box_publisher =
box_name =
provider =
family =
role =
playbook =

.DEFAULT_GOAL := help
.PHONY: help check install update box-add validate validate-soft plugins clean vm vm-root vm-migrate links

help:
	@echo "Available targets:"
	@echo "  make check                Verify required CLI tools are installed"
	@echo "  make install              Install all default boxes (supports any publisher/name)"
	@echo "  make update               Update all default boxes and prune old versions"
	@echo "  make box-add              Interactive add: prompts for publisher/name/provider"
	@echo "  make box-add box=publisher/name provider=virtualbox"
	@echo "                            Non-interactive add of one specific box"
	@echo "  make install BOXES='bento/ubuntu-24.04 gnome-shell-box/silverblue42'"
	@echo "                            Install a custom list of fully-qualified boxes"
	@echo "  make validate             Validate all Vagrantfiles in child directories"
	@echo "  make validate-soft        Validate all Vagrantfiles but always exit 0"
	@echo "  make plugins              Install commonly used Vagrant plugins"
	@echo "  make clean                Prune unused Vagrant boxes"
	@echo "  make vm                   Interactive VM creation in ./$(vm_root)/"
	@echo "  make vm name=myvm box=bento/ubuntu-24.04 role=server family=apt provider=virtualbox"
	@echo "                            Non-interactive VM creation in ./$(vm_root)/myvm"
	@echo "  make vm-root              Show current VM root and override example"
	@echo "  make vm-migrate name=myvm Move one root-level VM dir into ./$(vm_root)/myvm"
	@echo "  optional vm vars: role=server|workstation family=apt|rpm playbook=ansible-*-base provider=virtualbox|libvirt|vmware_desktop"
	@echo "  make links                Run 'make links' in child directories"

check:
	@for cmd in vagrant awk sed grep sort nl; do \
		if ! command -v $$cmd >/dev/null 2>&1; then \
			echo "Missing required command: $$cmd"; \
			exit 1; \
		fi; \
	done; \
	echo "All required commands are available."

install:
	@for box in $(BOXES); do \
		printf "\nInstalling $$box\n" && vagrant box add $$box --provider=$(hypervisor) --force; done
update:
	@for box in $(BOXES); do \
		printf "\nUpdating $$box\n" && vagrant box update --box $$box; done
	@vagrant box prune

box-add:
	@selected_box="$(box)"; \
	selected_publisher="$(box_publisher)"; \
	selected_name="$(box_name)"; \
	selected_provider="$(provider)"; \
	interactive_mode=0; \
	if [ -z "$$selected_box" ]; then \
		interactive_mode=1; \
		if [ -z "$$selected_publisher" ]; then \
			printf "Enter box publisher: "; \
			read -r selected_publisher; \
		fi; \
		if [ -z "$$selected_name" ]; then \
			printf "Enter box name: "; \
			read -r selected_name; \
		fi; \
		if [ -z "$$selected_publisher" ] || [ -z "$$selected_name" ]; then \
			echo "Publisher and box name are required."; \
			exit 1; \
		fi; \
		selected_box="$$selected_publisher/$$selected_name"; \
	fi; \
	if [ "$$interactive_mode" -eq 1 ] && [ -z "$$selected_provider" ]; then \
		echo "Select provider:"; \
		echo "  1) virtualbox"; \
		echo "  2) libvirt"; \
		echo "  3) vmware_desktop"; \
		printf "Choose provider [1-3] (default: $(hypervisor)): "; \
		read -r provider_choice; \
		case "$$provider_choice" in \
			"") selected_provider="$(hypervisor)" ;; \
			1) selected_provider="virtualbox" ;; \
			2) selected_provider="libvirt" ;; \
			3) selected_provider="vmware_desktop" ;; \
			*) selected_provider="" ;; \
		esac; \
	fi; \
	if [ -z "$$selected_provider" ]; then \
		selected_provider="$(hypervisor)"; \
	fi; \
	if ! printf '%s' "$$selected_box" | grep -Eq '^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$$'; then \
		echo "Box must be fully-qualified as publisher/name (example: gnome-shell-box/silverblue42)."; \
		exit 1; \
	fi; \
	if ! printf '%s' "$$selected_provider" | grep -Eq '^[A-Za-z0-9._-]+$$'; then \
		echo "Provider is required and may only contain letters, numbers, dot, underscore, and dash."; \
		exit 1; \
	fi; \
	printf "\nInstalling %s with provider %s\n" "$$selected_box" "$$selected_provider"; \
	vagrant box add "$$selected_box" --provider="$$selected_provider" --force

validate:
	@status=0; \
	for dir in */; do \
		if [ -d "$$dir" ] && [ -f "$$dir/Vagrantfile" ]; then \
			printf "\nValidating %s\n" "$$dir"; \
			( cd "$$dir" && vagrant validate ) || status=1; \
		fi; \
	done; \
	exit $$status

validate-soft:
	@for dir in */; do \
		if [ -d "$$dir" ] && [ -f "$$dir/Vagrantfile" ]; then \
			printf "\nValidating %s\n" "$$dir"; \
			( cd "$$dir" && vagrant validate ) || true; \
		fi; \
	done

plugins:
	vagrant plugin install vagrant-clean vagrant-hostmanager vagrant-auto_network vagrant-cachier vagrant-vbguest vagrant-scp 

clean:
	@vagrant box prune
	# @for i in `ls -d */`; do ( cd $i && make clean ) || true; done # this is just a command line reference

vm:
	@vm_name="$(name)"; \
	vm_root="$(vm_root)"; \
	vm_dir=""; \
	selected_box="$(box)"; \
	selected_family="$(family)"; \
	selected_role="$(role)"; \
	selected_playbook="$(playbook)"; \
	selected_provider="$(provider)"; \
	provisioners_link_target="../../provisioners/ansible"; \
	if [ -z "$$vm_name" ]; then \
		printf "Enter VM name: "; \
		read -r vm_name; \
	fi; \
	if [ -z "$$vm_name" ]; then \
		echo "VM name is required."; \
		exit 1; \
	fi; \
	if ! printf '%s' "$$vm_name" | grep -Eq '^[A-Za-z0-9._-]+$$'; then \
		echo "VM name may only contain letters, numbers, dot, underscore, and dash."; \
		exit 1; \
	fi; \
	if [ -z "$$selected_box" ]; then \
		boxes=$$(vagrant box list | awk '{print $$1}' | sort -u); \
		if [ -z "$$boxes" ]; then \
			echo "No installed Vagrant boxes found. Install one first with 'make install' or 'vagrant box add'."; \
			exit 1; \
		fi; \
		echo "Available installed boxes:"; \
		printf '%s\n' "$$boxes" | nl -w2 -s') '; \
		printf "Choose a box number: "; \
		read -r choice; \
		selected_box=$$(printf '%s\n' "$$boxes" | sed -n "$${choice}p"); \
	fi; \
	if [ -z "$$selected_box" ]; then \
		echo "A valid box selection is required."; \
		exit 1; \
	fi; \
	installed_providers=$$(vagrant box list | awk -v box="$$selected_box" '$$1 == box {print}' | sed -E 's/^[^ ]+ \(([^,]+),.*$$/\1/' | sort -u); \
	installed_provider_count=$$(printf '%s\n' "$$installed_providers" | grep -c . || true); \
	if [ -z "$$selected_provider" ]; then \
		if [ "$$installed_provider_count" -eq 1 ]; then \
			selected_provider=$$(printf '%s\n' "$$installed_providers" | sed -n '1p'); \
			echo "Using installed provider '$$selected_provider' for '$$selected_box'."; \
		elif [ "$$installed_provider_count" -gt 1 ]; then \
			echo "Installed providers for '$$selected_box':"; \
			printf '%s\n' "$$installed_providers" | nl -w2 -s') '; \
			printf "Choose provider number: "; \
			read -r provider_choice; \
			selected_provider=$$(printf '%s\n' "$$installed_providers" | sed -n "$${provider_choice}p"); \
		else \
			echo "Select provider:"; \
			echo "  1) virtualbox"; \
			echo "  2) libvirt"; \
			echo "  3) vmware_desktop"; \
			printf "Choose provider [1-3] (default: $(hypervisor)): "; \
			read -r provider_choice; \
			case "$$provider_choice" in \
				"") selected_provider="$(hypervisor)" ;; \
				1) selected_provider="virtualbox" ;; \
				2) selected_provider="libvirt" ;; \
				3) selected_provider="vmware_desktop" ;; \
				*) selected_provider="" ;; \
			esac; \
		fi; \
	fi; \
	if [ "$$selected_provider" != "virtualbox" ] && [ "$$selected_provider" != "libvirt" ] && [ "$$selected_provider" != "vmware_desktop" ]; then \
		echo "Provider must be one of: virtualbox, libvirt, vmware_desktop."; \
		exit 1; \
	fi; \
	if [ "$$installed_provider_count" -gt 0 ] && ! printf '%s\n' "$$installed_providers" | grep -Fxq "$$selected_provider"; then \
		echo "Provider '$$selected_provider' is not installed for box '$$selected_box'."; \
		echo "Installed providers for this box: $$installed_providers"; \
		echo "Install a matching box variant first, for example:"; \
		echo "  make box-add box=$$selected_box provider=$$selected_provider"; \
		exit 1; \
	fi; \
	if [ -z "$$selected_role" ]; then \
		echo "Select role:"; \
		echo "  1) server"; \
		echo "  2) workstation"; \
		printf "Choose role [1-2]: "; \
		read -r role_choice; \
		case "$$role_choice" in \
			1) selected_role="server" ;; \
			2) selected_role="workstation" ;; \
			*) selected_role="" ;; \
		esac; \
	fi; \
	if [ "$$selected_role" != "server" ] && [ "$$selected_role" != "workstation" ]; then \
		echo "Role must be 'server' or 'workstation'."; \
		exit 1; \
	fi; \
	if [ -z "$$selected_family" ]; then \
		case "$$selected_box" in \
			*ubuntu*|*debian*) selected_family="apt" ;; \
			*fedora*|*rocky*|*centos*|*rhel*) selected_family="rpm" ;; \
			*) \
				echo "Select package family:"; \
				echo "  1) apt"; \
				echo "  2) rpm"; \
				printf "Choose family [1-2]: "; \
				read -r family_choice; \
				case "$$family_choice" in \
					1) selected_family="apt" ;; \
					2) selected_family="rpm" ;; \
					*) selected_family="" ;; \
				esac ;; \
		esac; \
	fi; \
	if [ "$$selected_family" != "apt" ] && [ "$$selected_family" != "rpm" ]; then \
		echo "Family must be 'apt' or 'rpm'."; \
		exit 1; \
	fi; \
	if [ -z "$$selected_playbook" ]; then \
		if [ "$$selected_family" = "apt" ]; then \
			selected_playbook="ansible-ubuntu-base"; \
		else \
			case "$$selected_box" in \
				*rocky*|*centos*|*rhel*) selected_playbook="ansible-centos-base" ;; \
				*) selected_playbook="ansible-fedora-base" ;; \
			esac; \
		fi; \
	fi; \
	if [ "$$selected_role" = "server" ]; then \
		selected_setup_file="setup_server.yml"; \
	else \
		selected_setup_file="setup_workstation.yml"; \
	fi; \
	if [ ! -f "./provisioners/ansible/$$selected_playbook/$$selected_role/$$selected_setup_file" ]; then \
		echo "Provisioner file not found: ./provisioners/ansible/$$selected_playbook/$$selected_role/$$selected_setup_file"; \
		exit 1; \
	fi; \
	vm_dir="./$$vm_root/$$vm_name"; \
	mkdir -p "./$$vm_root"; \
	if [ -d "$$vm_dir" ]; then \
		echo "Directory '$$vm_dir' already exists. Choose a different VM name."; \
		exit 1; \
	fi; \
	cp -R ./template-vm "$$vm_dir"; \
	sed -i "s/template-vm/$$vm_name/g" "$$vm_dir/Vagrantfile"; \
	sed -i "s#^  config.vm.box = .*#  config.vm.box = '$$selected_box'#" "$$vm_dir/Vagrantfile"; \
	sed -i "s#^ANSIBLE_PLAYBOOK = .*#ANSIBLE_PLAYBOOK = '$$selected_playbook'.freeze#" "$$vm_dir/Vagrantfile"; \
	sed -i "s#^ANSIBLE_ROLE = .*#ANSIBLE_ROLE = '$$selected_role'.freeze#" "$$vm_dir/Vagrantfile"; \
	sed -i "s#^ANSIBLE_SETUP_FILE = .*#ANSIBLE_SETUP_FILE = '$$selected_setup_file'.freeze#" "$$vm_dir/Vagrantfile"; \
	sed -i "s#^VAGRANT_PROVIDER = .*#VAGRANT_PROVIDER = '$$selected_provider'.freeze#" "$$vm_dir/Vagrantfile"; \
	sed -i "s#ln -s ../provisioners/ansible \\.#ln -s $$provisioners_link_target .#" "$$vm_dir/Makefile"; \
	ln -s "$$provisioners_link_target" "$$vm_dir/ansible"; \
	echo "Created VM '$$vm_name' in '$$vm_dir' using box '$$selected_box', provider '$$selected_provider', and $$selected_playbook/$$selected_role." 

vm-root:
	@echo "Current VM root: ./$(vm_root)"
	@echo "Override example: make vm vm_root=.machines-lab name=myvm box=bento/ubuntu-24.04 role=server family=apt"

vm-migrate:
	@vm_name="$(name)"; \
	vm_root="$(vm_root)"; \
	src_dir=""; \
	dst_dir=""; \
	if [ -z "$$vm_name" ]; then \
		printf "Enter VM directory name to migrate: "; \
		read -r vm_name; \
	fi; \
	if [ -z "$$vm_name" ]; then \
		echo "VM directory name is required."; \
		exit 1; \
	fi; \
	if ! printf '%s' "$$vm_name" | grep -Eq '^[A-Za-z0-9._-]+$$'; then \
		echo "VM directory name may only contain letters, numbers, dot, underscore, and dash."; \
		exit 1; \
	fi; \
	src_dir="./$$vm_name"; \
	dst_dir="./$$vm_root/$$vm_name"; \
	if [ ! -d "$$src_dir" ]; then \
		echo "Source directory not found: $$src_dir"; \
		exit 1; \
	fi; \
	if [ ! -f "$$src_dir/Vagrantfile" ]; then \
		echo "Source does not look like a VM directory (missing Vagrantfile): $$src_dir"; \
		exit 1; \
	fi; \
	mkdir -p "./$$vm_root"; \
	if [ -e "$$dst_dir" ]; then \
		echo "Destination already exists: $$dst_dir"; \
		exit 1; \
	fi; \
	mv "$$src_dir" "$$dst_dir"; \
	echo "Migrated '$$src_dir' -> '$$dst_dir'"

links:
	@for dir in */; do \
		if [ -f "$$dir/Makefile" ]; then \
			$(MAKE) -C "$$dir" links || true; \
		fi; \
	done
