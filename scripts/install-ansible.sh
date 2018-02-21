#!/bin/bash -eux

# Install Ansible repository.
rm -f /vagrant/logs/install-ansible.log 2>/dev/null
mkdir -p /vagrant/logs
touch /vagrant/logs/install-ansible.log
apt-get -qq -y update | tee --append --output-error=exit /vagrant/logs/install-ansible.log
apt-get -qq -y install software-properties-common | tee --append --output-error=exit /vagrant/logs/install-ansible.log
apt-add-repository ppa:ansible/ansible | tee --append --output-error=exit /vagrant/logs/install-ansible.log

# Install Ansible.
apt-get -qq -y update | tee --append --output-error=exit /vagrant/logs/install-ansible.log
apt-get -qq -y install ansible | tee --append --output-error=exit /vagrant/logs/install-ansible.log
ansible --version | tee --append --output-error=exit /vagrant/logs/install-ansible.log
