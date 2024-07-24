LIST = rhel9 ubuntu2204 fedora39
targets = $(addprefix generic/, $(LIST))
hypervisor = libvirt
installed := $(vagrant box list)
name = 
box = 

install:
	@for box in $(targets); do \
		printf "\nInstalling $$box\n" && vagrant box add $$box --provider=$(hypervisor) --force; done
update:
	@for box in $(targets); do \
		printf "\nUpdating $$box\n" && vagrant box update --box $$box; done
	@vagrant box prune

validate:
	@for box in $(shell ls -d */); do \
  	cd $$box && printf "\nValidating $$box\n" $$box && vagrant validate || true && cd ..; done

plugins:
	vagrant plugin install vagrant-clean vagrant-hostmanager vagrant-auto_network vagrant-cachier vagrant-vbguest vagrant-scp 

clean:
	@vagrant box prune
	# @for i in `ls -d */`; do ( cd $i && make clean ) || true; done # this is just a command line reference

vm: 
	test -n "${name}" ## Please name your VM: name=somename
	test -n "${box}" ## Please specify your box: box=somebox
	@cp -R ./template-vm ./$(name)
	@sed -i 's/template-vm/$(name)/g' ./$(name)/Vagrantfile
	@sed -i 's/generic\/$(name)/generic\/$(box)/g' ./$(name)/Vagrantfile
	@ln -s ./provisioners/ansible ./$(name)/ansible

links:
	@for i in `ls -d */`; do ( cd $i && make links ) || true; done
