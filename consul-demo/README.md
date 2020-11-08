# Consul Demo

### Running the demo

This demo will spin up a total of 6 servers, to show the entire use of Consul with funtioning applications.

First, you will want to make sure that you have the latest version of Vagrant. The version this is wrote on is 2.2.13, so there may be additional updates required at a later time based on versions.

Second, you will want to have a few plugins for Vagrant to make it easiser to use:

- vagrant-auto_network
- vagrant-hostmanager

Installing these plugins can be done with the following commands:

```
vagrant plugin install vagrant-auto_network vagrant-hostmanager
```

Once you have Vagrant and all of the plugins you will want to run the Vagrant commands to bring up the servers:

```
vagrant up
```

You can then connect to: ` http://n1:8500/ui`
