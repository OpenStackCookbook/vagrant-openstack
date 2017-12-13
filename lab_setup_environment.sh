#!/bin/bash

RUNDIR="."

# Determine if we're running from the openstack-client vm
if [[ $(hostname -s) == "openstack-client" ]]
then
	RUNDIR="/vagrant"
fi

# Source credentials
. ${RUNDIR}/openrc

# Create a flavor
openstack flavor create --ram 512 --disk 0 --vcpus 1 --public m1.tiny

# Create the external gateway network: 192.168.100.0/24 via 'flat' bridge (eth3 in the guest)
openstack network create --share --project admin --external --default --provider-network-type flat --provider-physical-network flat GATEWAY_NET
openstack subnet create --project admin --subnet-range 192.168.100.0/24 --dhcp --dns-nameserver 192.168.1.1 --gateway 192.168.1.1 --allocation-pool start=192.168.100.100,end=192.168.100.250 --network GATEWAY_NET GATEWAY_SUBNET

# Create a private tenant network (VXLAN)
openstack network create --project admin private-net
openstack subnet create --project admin --subnet-range 10.10.10.0/24 --dhcp --dns-nameserver 192.168.1.1 --network private-net private-subnet

# Create a router
openstack router create myRouter

# Connect the two networks
openstack router add subnet myRouter private-subnet
openstack router set myRouter --external-gateway GATEWAY_NET

# As the flat network doesn't really route anywhere, but the host running this environment can, add a static route
# to the router to send traffic from the flat network (which is the "gateway" to the instance) to the host's IP on the flat network
# In this case, the host is on 192.168.1.0/24 subnet and the host's interface on flat is 192.168.100.1
openstack router set --route destination=192.168.1.0/24,gateway=192.168.100.1 myRouter

# Add some useful default security group rules
ADMIN_PROJECT=$(openstack project list | awk '/admin/ {print $2}')
DEFAULT_SEC_GROUP=$(openstack security group list | awk "/${ADMIN_PROJECT}/ {print \$2}")
openstack security group rule create --remote-ip 0.0.0.0/0 --dst-port 22:22 --protocol tcp --ingress --project admin ${DEFAULT_SEC_GROUP}
openstack security group rule create --remote-ip 0.0.0.0/0 --protocol icmp --ingress --project admin ${DEFAULT_SEC_GROUP}

# Add the key (created on vagrant up) as a key to also be used to access guests
openstack keypair create --public-key /vagrant/id_rsa.pub demokey

# Lazy stuff to do with the example heat template: update the environment file with the created network UUIDs
PUB_NET=$(openstack network list | awk '/GATEWAY_NET/ {print $2}')
PRIV_NET=$(openstack network list | awk '/private/ {print $2}')
PRIV_SUBNET=$(openstack subnet list | awk '/private/ {print $2}')

sed -i "s/public_net_id.*/public_net_id: ${PUB_NET}/" ${RUNDIR}/cookbook-env.yaml 
sed -i "s/private_net_id.*/private_net_id: ${PRIV_NET}/" ${RUNDIR}/cookbook-env.yaml 
sed -i "s/private_subnet_id.*/private_subnet_id: ${PRIV_SUBNET}/" ${RUNDIR}/cookbook-env.yaml 
