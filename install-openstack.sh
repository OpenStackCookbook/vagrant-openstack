#!/bin/bash

set -ex

#TAG=10.1.4
TAG=11.0.1

COMPUTES="compute-01"
#compute-02"

CONTROLLERS="controller-01
controller-02
controller-03"

HOSTS="logging
$COMPUTES
$CONTROLLERS"

RETRY=5

RPC_REPO=ansible-lxc-rpc

ap() {
	ansible-playbook -e @/etc/openstack_deploy/user_variables.yml "$@"
	#ansible-playbook "$@"
}


reset_environment() {
	cd /root/ansible-lxc-rpc/openstack_deployment
	ap playbooks/setup/destroy-containers.yml
	ansible hosts -m shell -a 'rm -fr /openstack'
	ansible hosts -m shell -a 'rm -fr /var/lib/lxc/*'
	ansible hosts -m shell -a 'lvremove lxc -f'
	rm -f /etc/openstack_deploy/rpc_inventory.json
	rm -f /root/*.retry

	# Hosts file
	for a in {1..7}; do
	ssh openstack${a} "head -7 /etc/hosts > /tmp/hosts.tmp; rm -f /etc/hosts; mv /tmp/hosts.tmp /etc/hosts"; done
}

get_playbooks() {
	cd /opt
	rm -rf os-ansible-deployment
	git clone -b ${TAG} https://github.com/stackforge/os-ansible-deployment.git
	# Fix the http/https rackspace repo error
        sed -i 's,http\:\/\/rpc\-repo,https://rpc-repo,g' /opt/os-ansible-deployment/playbooks/inventory/group_vars/all.yml
}

install_pip() {

	curl -O https://bootstrap.pypa.io/get-pip.py
	python get-pip.py --trusted-host mirror.rackspace.com --find-links="http://mirror.rackspace.com/rackspaceprivatecloud/python_packages/master" --no-index
}

install_ansible() {
	# pip install -r /opt/os-ansible-deployment/requirements.txt
	cd /opt/os-ansible-deployment
	scripts/bootstrap-ansible.sh
	cd /opt
}

configure_deployment() {
	cp -R /opt/os-ansible-deployment/etc/openstack_deploy /etc
	if [[ -f /etc/openstack_deploy/rpc_user_config.yml ]]; then mv /etc/openstack_deploy/rpc_user_config.yml{,.bak}; fi
	if [[ -f /etc/openstack_deploy/user_variables ]]; then mv /etc/openstack_deploy/user_variables.yml{,.bak}; fi

	cp /vagrant/openstack_user_config.yml /etc/openstack_deploy/openstack_user_config.yml
	cp /vagrant/user_variables.yml /etc/openstack_deploy/user_variables.yml
	cd /opt/os-ansible-deployment
        scripts/pw-token-gen.py --file /etc/openstack_deploy/user_secrets.yml
	
	# Remove swift artifact
	rm -f /etc/openstack_deploy/conf.d/swift.yml
}

pre_deploy_containers() {
	# Grab container from local FTP instead of waiting a bajillion years and endless retries
	for a in ${HOSTS}
	do
		ssh ${a} "mkdir -p /var/cache/lxc; wget -O /var/cache/lxc/rpc-trusty-container.tgz ftp://nas2/Public/ubuntu/rpc-trusty-container.tgz"
	done
}

install_foundation_playbooks() {
	cd /opt/os-ansible-deployment/playbooks
	ap setup-hosts.yml
}


install_infra_playbooks() {
	cd /opt/os-ansible-deployment/playbooks
	ap haproxy-install.yml
	ap setup-infrastructure.yml
}

check_galera() {
	# MySQL Test
	mysql -uroot -psecrete -h 192.168.100.201 -e 'show status;'
	STATUS=$?
	if [[ $STATUS != 0 ]]
	then
		echo "Check MariaDB/Galera. Unable to connect."
		exit 1
	fi
}

install_openstack_playbooks() {
	cd /opt/os-ansible-deployment/playbooks
	ap setup-openstack.yml
}

fixup_flat_networking() {
	for a in $COMPUTES; do ssh -n ${a} "sed -i 's/vlan:br-vlan/vlan:eth11/g' /etc/neutron/plugins/ml2/ml2_conf.ini; restart neutron-linuxbridge-agent"; done
}

#reset_environment
get_playbooks
install_pip
install_ansible
configure_deployment
pre_deploy_containers
install_foundation_playbooks
install_infra_playbooks
check_galera
install_openstack_playbooks
fixup_flat_networking

# List Inventory Contents
#~/ansible-lxc-rpc/scripts/inventory-manage.py -f /etc/openstack_deploy/rpc_inventory.json --list-host
