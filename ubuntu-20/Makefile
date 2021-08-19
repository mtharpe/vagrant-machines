links:
	echo "Setting symlinks for provisioners"
	@ln -s ../provisioners/ansible .

clean:
	echo "Removing symlinks for provisioners"
	@unlink ansible || true

start:
	$(MAKE) links
	vagrant up

stop:
	vagrant destroy -f
	$(MAKE) clean
