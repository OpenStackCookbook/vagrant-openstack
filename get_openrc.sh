#!/bin/bash
# Gets openrc credentials from the utility container on controller-01
vagrant ssh controller-01 -c "sudo ssh \$(sudo lxc-ls -f | awk '/utility/ {print \$1}') cat openrc > /vagrant/openrc"
