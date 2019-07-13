# vagrant-openstack Rocky
Vagrant environment that uses [OpenStack Ansible](https://github.com/openstack/openstack-ansible) for deploying OpenStack.<br>
Contributors:
- Kevin Jackson (@itarchitectkev)
- Cody Bunch (@bunchc)
- James Denton (@jimmdenton)

Additional Contributors:
- Wojciech Sciesinski (@ITpraktyk)
- Geoff Higginbottom (@the_cloudguru)

<!---
# View the demo!
[![Vagrant Up Demo](https://asciinema.org/a/sPAcxfGUSAYsDJy9LTXGZoLR1.png)](https://asciinema.org/a/sPAcxfGUSAYsDJy9LTXGZoLR1)
-->

# Requirements
- Vagrant (recommended 1.8+)
- Vagrant plugins - [Installation instructions](https://www.vagrantup.com/docs/plugins/usage.html)
  - [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager)  
  - [vagrant-triggers](https://github.com/emyl/vagrant-triggers)
- VirtualBox 4.3+ (Tested on VirtualBox 5.1)
- Git (to check out this environment)
- NFSD enabled on Mac and Linux environments to allow guest /vagrant access

# Instructions
```
git clone https://github.com/OpenStackCookbook/vagrant-openstack.git
cd vagrant-openstack
vagrant up
```

Time to deploy: 1 - 2 hours.

Horizon interface will be @ https://192.168.100.10/

Details of access can be found in the controller-01 utility container:

```
./get_openrc.sh
```
Or manually
```
vagrant ssh controller-01
sudo -i
lxc-attach -n $(lxc-ls -f | awk '/utility/ {print $1}')
cat openrc
```

# Troubleshooting
The OpenStack-Ansible playbooks output to the following files:
- setup-hosts.log
- setup-infrastructure.log
- setup-openstack.log

In a seperate terminal execute the following exactly as stated; ignoring the warning about the files not existing (yet):
```
tail -F setup-hosts.log setup-infrastructure.log setup-openstack.log
```
This will produce the Ansible output that would otherwise be hidden by Vagrant

# Environment
Deploys 3 machines:

controller-01 (2vCPU, 6Gb Ram)<br>
compute-01 (1vCPU, 4Gb Ram)<br>
openstack-client (1vCPU, 1Gb Ram)<br>

# Networking
eth0 - nat (used by VMware/VirtualBox)<br>
eth1 - br-mgmt (Container) 172.29.236.0/24<br>
eth2 - br-vlan (Neutron VLAN network) 0.0.0.0/0<br>
eth3 - host / API 192.168.100.0/24<br>
eth4 - br-vxlan (Neutron VXLAN Tunnel network) 172.29.240.0/24<br>

Note: check your VirtualBox/Fusion/Workstation networking and remove any conflicts.<br>
Any amendments are done in the file called Vagrantfile:<br>

```
box.vm.network :private_network, ip: "172.29.236.#{ip_start+i}", :netmask => "255.255.255.0"
box.vm.network :private_network, ip: "10.10.0.#{ip_start+i}", :netmask => "255.255.255.0"
box.vm.network :private_network, ip: "192.168.100.#{ip_start+i}", :netmask => "255.255.255.0"
box.vm.network :private_network, ip: "172.29.240.#{ip_start+i}", :netmask => "255.255.255.0
```

# Demo Script
Review the script lab_environment_setup.sh file and edit to suit. It's a basic shell script that will:
- Upload a Cirros or Xenial Image if they exist in your current working directory (/vagrant as seen by guests)
- Create a couple of networks: private network; public network on 192.168.100.0/24 (eth3 from above)
- Upload your vagrant ssh key
- Modify the example cookbook Heat template to match the example resources loaded

The openrc OpenStack credentials have been put into a file called /vagrant/openrc (which is 'openrc' from the directory you launched vagrant up):<br>
Now load some images into OpenStack using the following script:
```
./load_images.sh
```
Now access the openstack-client VM:
```
vagrant ssh openstack-client
```
Now run the following commands:
```
. /vagrant/openrc        # Source the credentials
/vagrant/lab_environment_setup.sh
openstack stack create -t /vagrant/cookbook.yaml -e /vagrant/cookbook-env.yaml myStack
```
# Resuming a suspended lab
The containers start in a random order following a VM resume, so this dirty hack will reboot the API service containers for you so you can get back to working in your lab again:
```
vagrant reload
./resume_environment.sh
```

