#!/bin/bash

# sort out keys for root user
sudo ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
rm -f /vagrant/id_rsa*
sudo cp /root/.ssh/id_rsa* /vagrant
#sudo cp /root/.ssh/id_rsa.pub /vagrant
chmod 0600 /vagrant/id_rsa*
cat /vagrant/id_rsa.pub | sudo tee -a /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys
cat /vagrant/id_rsa.pub | sudo tee -a /home/vagrant/.ssh/authorized_keys
chmod 0600 /root/.ssh/id_rsa*

# Write out /root/.ssh/config
echo "
BatchMode yes
CheckHostIP no
StrictHostKeyChecking no" > /root/.ssh/config
chmod 0600 /root/.ssh/config
