#!/bin/bash

mkdir -p --mode=0700 /root/.ssh

cat /vagrant/id_rsa.pub | sudo tee -a /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys

cat /vagrant/id_rsa.pub | sudo tee -a /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys

cp /vagrant/id_rsa* ~/.ssh/
chmod 0600 /home/vagrant/.ssh/id_rsa*

# Write out /root/.ssh/config
echo "
BatchMode yes
CheckHostIP no
StrictHostKeyChecking no" > /root/.ssh/config
chmod 0600 /root/.ssh/config
