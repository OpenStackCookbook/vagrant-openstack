#!/bin/bash

# Grab the images and use the openstack-client VM to load them into OpenStack

# Load some images
CIRROS=cirros-0.4.0-x86_64-disk.img
UBUNTU=ubuntu-16.04-server-cloudimg-amd64-disk1.img

if [[ ! -f ${UBUNTU} ]]
then
	wget https://cloud-images.ubuntu.com/releases/16.04/release/${UBUNTU}
fi

if [[ ! -f ${CIRROS} ]]
then
	wget https://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
fi

vagrant ssh openstack-client -c ". /vagrant/openrc; openstack image create --container-format bare --disk-format qcow2 --public --file /vagrant/ubuntu-16.04-server-cloudimg-amd64-disk1.img xenial-image; openstack image create --container-format bare --disk-format qcow2 --public --file /vagrant/cirros-0.4.0-x86_64-disk.img cirros-image"
