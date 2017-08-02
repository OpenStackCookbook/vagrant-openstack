# vagrant-openstack
Vagrant environment that uses https://github.com/openstack/openstack-ansible for deploying OpenStack.<br>
Contributors
- Kevin Jackson (@itarchitectkev)
- Cody Bunch (@bunchc)

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
vagrant ssh controller-01
sudo -i
lxc-attach -n $(lxc-ls -f | awk '/utility/ {print $1}')
cat openrc
```

# Environment
Deploys 2 machines:

controller-01 (2vCPU, 6Gb Ram)<br>
compute-01 (1vCPU, 4Gb Ram)<br>

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
Check out the lab_environment_setup.sh file.<br>
Modify openrc file (grab from the utility container as described above) and place in the same directory from where you're running the script.<br>
<br>
It assumes you have downloaded Cirros and Ubuntu Xenial. It will load them up, create a couple of networks, router, flavor, security group and keys.<br>
It will also edit a heat template environment file based on the created networks.<br>
Once run, execute:<br>
```
. openrc
./lab_environment_setup.sh
openstack stack create -t cookbook.yaml -e cookbook-env.yaml myStack
```
