links:
	echo "Setting symlinks for provisioners"
	@ln -s ../provisioners/ansible .
	@ln -s ../provisioners/chef/cookbooks .
	@ln -s ../provisioners/chef/nodes .

clean:
	echo "Removing symlinks for provisioners"
	@unlink ansible || true
	@unlink cookbooks || true
	@unlink nodes || true