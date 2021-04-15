LIST = centos6 centos7 centos8 rhel6 rhel7 rhel8 ubuntu1604 ubuntu1804 ubuntu2004 fedora32 fedora33 
targets = $(addprefix generic/, $(LIST))
hypervisor = virtualbox
installed := $(vagrant box list)
name = 
box = 

install:
	@for box in $(targets); do \
		printf "\nInstalling $$box\n" && vagrant box add $$box --provider=$(hypervisor); done
update:
	@for box in $(targets); do \
		printf "\nUpdating $$box\n" && vagrant box update --box $$box; done
	@vagrant box prune

validate:
	@for box in $(shell ls -d */); do \
  	cd $$box && printf "\nValidating $$box\n" $$box && vagrant validate || true && cd ..; done

plugins:
	vagrant plugin install vagrant-hostmanager vagrant-berkshelf vagrant-clean vagrant-auto_network vagrant-cachier vagrant-vbguest vagrant-scp 

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
	@ln -s ./provisioners/chef/cookbooks ./$(name)/cookbooks
	@ln -s ./provisioners/chef/nodes ./$(name)/nodes

links:
	@for i in `ls -d */`; do ( cd $i && make links ) || true; done
