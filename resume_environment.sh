#!/bin/bash

# If you're not spinning up or down the environment every time you want to use it
# you may realise that the containers don't come up in any order that makes sense
# after a VM resume.
# This little hack of a script will restart the API service containers for you

if [[ $(hostname -s) == "controller-01" ]]; then

	sudo lxc-ls -f | egrep -v "NAME|galera|rabbit|utility|rsyslog|repo" | awk '{print $1}' | while read C; do echo "Rebooting ${C}"; sudo lxc-stop -r -n ${C}; done

elif [[ $(hostname -s) == "openstack-client" ]]; then

	ssh controller-01 "sudo lxc-ls -f | egrep -v \"NAME|galera|rabbit|utility|rsyslog|repo\" | awk '{print \$1}' | while read C; do echo \"Rebooting \${C}\"; sudo lxc-stop -r -n \${C}; done"

else

	vagrant ssh controller-01 -c "sudo lxc-ls -f | egrep -v \"NAME|galera|rabbit|utility|rsyslog|repo\" | awk '{print \$1}' | while read C; do echo \"Rebooting \${C}\"; sudo lxc-stop -r -n \${C}; done"

fi
