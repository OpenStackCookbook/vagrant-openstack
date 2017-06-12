#!/bin/bash

#sudo cp /vagrant/openstack.cfg /etc/network/interfaces.d/
echo "source /etc/network/interfaces.d/*.cfg" >> /etc/network/interfaces

IP=$(ifconfig eth1 | awk '/inet addr/ {split ($2,A,":"); print A[2]}' | cut -d '.' -f4)

sed -i "s/__IP__/${IP}/g" /etc/network/interfaces.d/openstack.cfg
#/etc/init.d/networking restart
ifdown eth1
ifdown eth2
ifdown eth3
ifup br-mgmt
ifup br-vlan
ifup br-vxlan
ifup eth1
ifup eth2
ifup eth3
