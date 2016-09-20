#!/bin/bash

# This shells into logging and tells logging to execute /vagrant/install-openstack.sh
ssh -i /vagrant/id_rsa root@logging.cook.book "/vagrant/install-openstack2.sh"
