LIST = centos7 centos8 rhel7 rhel8 ubuntu1604 ubuntu1804 ubuntu2004 fedora32 fedora33 
targets = $(addprefix generic/, $(LIST))
hypervisor = virtualbox
installed := $(vagrant box list)
name = no-name
box = ubuntu1804

install:
	@for box in $(targets); do \
		printf "\nInstalling $$box\n" && vagrant box add $$box --provider=$(hypervisor); done
update:
	@for box in $(targets); do \
		printf "\nUpdating $$box\n" && vagrant box update --box $$box; done

validate:
	@for box in $(shell ls -d */); do \
  	cd $$box && printf "\nValidating $$box\n" $$box && vagrant validate || true && cd ..; done

plugins:
	vagrant plugin install vagrant-hostmanager vagrant-berkshelf vagrant-clean vagrant-auto_network vagrant-cachier vagrant-vbguest vagrant-scp 

clean:
	@vagrant box prune

vm:
	@cp -R ./template-vm ./$(name) 
	@sed -i '' 's/template-vm/$(name)/g' ./$(name)/Vagrantfile
	@sed -i '' 's/generic\/$(name)/generic\/$(box)/g' ./$(name)/Vagrantfile
