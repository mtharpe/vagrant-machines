# Default qemu-compatible boxes. Override with: `make install BOXES='foo/bar baz/qux'`.
# Find more at https://app.vagrantup.com/boxes/search?provider=qemu
BOXES ?= \
	perk/ubuntu-2204-arm64 \
	gyptazy/ubuntu24.04-arm64 \
	gyptazy/ubuntu24.04-amd64 \
	gyptazy/rocky9-amd64
hypervisor = qemu
vm_root = .machines
name =
box =
box_publisher =
box_name =
family =
role =
playbook =

.DEFAULT_GOAL := help
.PHONY: help check install update box-add validate validate-soft plugins clean vm vm-root vm-migrate links

help:
	@echo "Available targets:"
	@echo "  make check                Verify required CLI tools are installed"
	@echo "  make install              Install all default qemu boxes"
	@echo "  make update               Update all default boxes and prune old versions"
	@echo "  make box-add              Interactive add: prompts for publisher/name (qemu provider)"
	@echo "  make box-add box=publisher/name"
	@echo "                            Non-interactive add of one specific box"
	@echo "  make install BOXES='perk/ubuntu-2204-arm64 gyptazy/ubuntu24.04-amd64'"
	@echo "                            Install a custom list of fully-qualified boxes"
	@echo "  make validate             Validate all Vagrantfiles in child directories"
	@echo "  make validate-soft        Validate all Vagrantfiles but always exit 0"
	@echo "  make plugins              Install vagrant-qemu (the QEMU provider plugin)"
	@echo "  make clean                Prune unused Vagrant boxes"
	@echo "  make vm                   Interactive VM creation in ./$(vm_root)/"
	@echo "  make vm name=myvm box=gyptazy/ubuntu24.04-amd64 role=server family=apt"
	@echo "                            Non-interactive VM creation in ./$(vm_root)/myvm"
	@echo "  make vm-root              Show current VM root and override example"
	@echo "  make vm-migrate name=myvm Move one root-level VM dir into ./$(vm_root)/myvm"
	@echo "  optional vm vars: role=server|workstation family=apt|rpm playbook=ansible-*-base"
	@echo "  make links                Run 'make links' in child directories"

check:
	@for cmd in vagrant qemu-system-x86_64 qemu-system-aarch64 awk sed grep sort nl; do \
		if ! command -v $$cmd >/dev/null 2>&1; then \
			echo "Missing required command: $$cmd"; \
			exit 1; \
		fi; \
	done; \
	echo "All required commands are available."; \
	if ! vagrant plugin list 2>/dev/null | grep -q '^vagrant-qemu '; then \
		echo "Missing Vagrant plugin: vagrant-qemu (run 'make plugins')."; \
		exit 1; \
	fi; \
	echo "vagrant-qemu plugin is installed."

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
	if [ -z "$$selected_box" ]; then \
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
	if ! printf '%s' "$$selected_box" | grep -Eq '^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$$'; then \
		echo "Box must be fully-qualified as publisher/name (example: gyptazy/ubuntu24.04-amd64)."; \
		exit 1; \
	fi; \
	printf "\nInstalling %s with provider %s\n" "$$selected_box" "$(hypervisor)"; \
	vagrant box add "$$selected_box" --provider="$(hypervisor)" --force

validate:
	@status=0; \
	for dir in ./template-vm ./$(vm_root)/*/; do \
		if [ -d "$$dir" ] && [ -f "$$dir/Vagrantfile" ]; then \
			printf "\nValidating %s\n" "$$dir"; \
			( cd "$$dir" && vagrant validate ) || status=1; \
		fi; \
	done; \
	exit $$status

validate-soft:
	@for dir in ./template-vm ./$(vm_root)/*/; do \
		if [ -d "$$dir" ] && [ -f "$$dir/Vagrantfile" ]; then \
			printf "\nValidating %s\n" "$$dir"; \
			( cd "$$dir" && vagrant validate ) || true; \
		fi; \
	done

plugins:
	vagrant plugin install vagrant-qemu

clean:
	@vagrant box prune

vm:
	@vm_name="$(name)"; \
	vm_root="$(vm_root)"; \
	vm_dir=""; \
	selected_box="$(box)"; \
	selected_family="$(family)"; \
	selected_role="$(role)"; \
	selected_playbook="$(playbook)"; \
	provisioners_link_target="../../../provisioners/ansible"; \
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
		boxes=$$(vagrant box list | awk '/\(qemu,/ {print $$1}' | sort -u); \
		if [ -z "$$boxes" ]; then \
			echo "No installed qemu boxes found. Install one first with 'make install' or 'make box-add box=publisher/name'."; \
			exit 1; \
		fi; \
		echo "Available installed qemu boxes:"; \
		printf '%s\n' "$$boxes" | nl -w2 -s') '; \
		printf "Choose a box number: "; \
		read -r choice; \
		selected_box=$$(printf '%s\n' "$$boxes" | sed -n "$${choice}p"); \
	fi; \
	if [ -z "$$selected_box" ]; then \
		echo "A valid box selection is required."; \
		exit 1; \
	fi; \
	if ! vagrant box list | awk '/\(qemu,/ {print $$1}' | grep -Fxq "$$selected_box"; then \
		echo "Box '$$selected_box' is not installed for the qemu provider."; \
		echo "Install it first:"; \
		echo "  make box-add box=$$selected_box"; \
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
	if [ ! -f "../provisioners/ansible/$$selected_playbook/$$selected_role/$$selected_setup_file" ]; then \
		echo "Provisioner file not found: ../provisioners/ansible/$$selected_playbook/$$selected_role/$$selected_setup_file"; \
		exit 1; \
	fi; \
	vm_dir="./$$vm_root/$$vm_name"; \
	mkdir -p "./$$vm_root"; \
	if [ -d "$$vm_dir" ]; then \
		echo "Directory '$$vm_dir' already exists. Choose a different VM name."; \
		exit 1; \
	fi; \
	cp -R ./template-vm "$$vm_dir"; \
	sed -i '' "s/template-vm/$$vm_name/g" "$$vm_dir/Vagrantfile"; \
	sed -i '' "s#^QEMU_BOX = .*#QEMU_BOX = '$$selected_box'.freeze#" "$$vm_dir/Vagrantfile"; \
	sed -i '' "s#^ANSIBLE_PLAYBOOK = .*#ANSIBLE_PLAYBOOK = '$$selected_playbook'.freeze#" "$$vm_dir/Vagrantfile"; \
	sed -i '' "s#^ANSIBLE_ROLE = .*#ANSIBLE_ROLE = '$$selected_role'.freeze#" "$$vm_dir/Vagrantfile"; \
	sed -i '' "s#^ANSIBLE_SETUP_FILE = .*#ANSIBLE_SETUP_FILE = '$$selected_setup_file'.freeze#" "$$vm_dir/Vagrantfile"; \
	sed -i '' "s#ln -s ../provisioners/ansible \\.#ln -s $$provisioners_link_target .#" "$$vm_dir/Makefile"; \
	ln -s "$$provisioners_link_target" "$$vm_dir/ansible"; \
	echo "Created VM '$$vm_name' in '$$vm_dir' using box '$$selected_box' (qemu) and $$selected_playbook/$$selected_role."

vm-root:
	@echo "Current VM root: ./$(vm_root)"
	@echo "Override example: make vm vm_root=.machines-lab name=myvm box=gyptazy/ubuntu24.04-amd64 role=server family=apt"

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
