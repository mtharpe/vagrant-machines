links:
	echo "Setting symlinks for provisioners"
	@ln -s ../provisioners/ansible .

clean:
	echo "Removing symlinks for provisioners"
	@unlink ansible || true
	@rm -rf .vagrant

ssh:
	echo "starting Vagrant machine and will connect via ssh after it boots!"
	@vagrant ssh

gui:
	echo "Starting Vagrant machine and will open viewer after it boots!"
	@virt-viewer -r always --connect qemu:///system centos-8_default