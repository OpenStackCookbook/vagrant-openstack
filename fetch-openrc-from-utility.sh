#!/bin/bash
if [[ $(hostname -s) == "controller-01" ]]; then

	# Gets openrc credentials from the utility container on controller-01
	sudo ssh $(sudo lxc-ls -f | awk '/utility/ {print $1}') cat openrc > /vagrant/openrc

elif [[ $(hostname -s)  == "openstack-client"  ]]; then

	ssh controller-01 "sudo /vagrant/fetch-openrc-from-utility.sh"

else

	vagrant ssh controller-01 -c "sudo /vagrant/fetch-openrc-from-utility.sh"

fi
