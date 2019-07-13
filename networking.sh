#!/bin/bash

echo "source /etc/network/interfaces.d/*.cfg" >> /etc/network/interfaces

IP=$(ifconfig eth1 | awk '/inet\ / {print $2}' | cut -d '.' -f4)

sed -i "s/__IP__/${IP}/g" /etc/network/interfaces.d/openstack.cfg

#systemctl restart networking.service

ifdown eth1
ifdown eth2
ifdown eth3
ifdown eth4
ifup br-mgmt
ifup br-vlan
ifup br-flat
ifup br-vxlan
ifup eth1
ifup eth2
ifup eth3
ifup eth4
ip addr flush dev eth1
ip addr flush dev eth2
ip addr flush dev eth3
ip addr flush dev eth4
#ip link set eth2 promisc on
#ip link set eth3 promisc on
#ip link set eth4 promisc on
