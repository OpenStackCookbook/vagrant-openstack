#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
echo "set grub-pc/install_devices /dev/sda" | debconf-communicate

sudo apt-get update
#sudo apt-get -y upgrade -y
sudo apt-get -y install python-pip python-dev libffi-dev libssl-dev

# OpenStack Client Bits

sudo -H pip install --upgrade setuptools
sudo -H pip install -r /vagrant/requirements.txt
sudo -H pip install -U python-openstackclient
sudo -H pip install -U python-glancelcient
sudo -H pip install -U python-novaclient
sudo -H pip install -U python-neutronclient
sudo -H pip install -U python-heatclient
sudo -H pip install -U python-cinderclient
sudo -H pip install -U python-swiftclient

# Ansible Bits

sudo apt-get -y install software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update 
sudo apt-get -y install ansible
sudo pip install shade

if [[ -f /vagrant/openrc ]]
then
	sudo cp /vagrant/openrc /root
	sudo cp /vagrant/openrc .
fi
