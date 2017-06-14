# ansible-openstack
Vagrant environment that uses https://github.com/stackforge/os-ansible-deployment for deploying OpenStack.<br>
By Kevin Jackson (@itarchitectkev) and Cody Bunch (@bunchc)<br>

# Requirements
- Vagrant (recommended 1.8+)
- VirtualBox 4.3+ (Tested on VirtualBox 5.1)
- Git (to check out this environment)

# Instructions
```
git clone https://github.com/uksysadmin/ansible-openstack.git
cd ansible-openstack
vagrant up
```

Time to deploy: 1 - 2 hours.

Horizon interface will be @ https://192.168.100.10/

Details of access can be found in the controller-01 utility container:

```
vagrant ssh controller-01
sudo -i
lxc-attach -n (lxc-ls | grep utility)
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

