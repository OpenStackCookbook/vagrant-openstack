#!/bin/bash

COMPUTES="compute-01
compute-02"

CONTROLLERS="controller-01
controller-02
controller-03"

HOSTS="logging
$COMPUTES
$CONTROLLERS"

RETRY=5

RPC_REPO=ansible-lxc-rpc

ap() {
	ansible-playbook -e @/etc/rpc_deploy/user_variables.yml "$@"
}

install_preqs() {
	apt-get update
	apt-get -y upgrade
}

reset_environment() {
	cd /root/ansible-lxc-rpc/rpc_deployment
	ap playbooks/setup/destroy-containers.yml
	ansible hosts -m shell -a 'rm -fr /openstack'
	ansible hosts -m shell -a 'rm -fr /var/lib/lxc/*'
	ansible hosts -m shell -a 'lvremove lxc -f'
	rm -f /etc/rpc_deploy/rpc_inventory.json
	rm -f /root/*.retry

	# Hosts file
	for a in {1..7}; do
	ssh openstack${a} "head -7 /etc/hosts > /tmp/hosts.tmp; rm -f /etc/hosts; mv /tmp/hosts.tmp /etc/hosts"; done
}

get_playbooks() {
	cd /opt
	git clone -b 10.1.3 https://github.com/stackforge/os-ansible-deployment.git
}

install_pip() {

	curl -O https://bootstrap.pypa.io/get-pip.py
	python get-pip.py --trusted-host mirror.rackspace.com --find-links="http://mirror.rackspace.com/rackspaceprivatecloud/python_packages/juno" --no-index
}

install_ansible() {
	pip install -r /opt/os-ansible-deployment/requirements.txt
}

configure_deployment() {
	cp -r ~/${RPC_REPO}/etc/rpc_deploy /etc
	if [[ -f /etc/rpc_deploy/rpc_user_config.yml ]]; then mv /etc/rpc_deploy/rpc_user_config.yml{,.bak}; fi

	wget -O /etc/rpc_deploy/rpc_user_config.yml ftp://192.168.1.2/Public/ubuntu/rpc_user_config.yml
	wget -O /etc/rpc_deploy/user_variables.yml ftp://192.168.1.2/Public/ubuntu/user_variables.yml
}

pre_deploy_containers() {
	# Grab container from local FTP instead of waiting a bajillion years and endless retries
	for a in {1..7}
	do
		ssh openstack${a} wget -O /var/cache/lxc/rpc-trusty-container.tgz ftp://nas2/Public/ubuntu/rpc-trusty-container.tgz
	done
}

install_foundation_playbooks() {
	cd ~/ansible-lxc-rpc/rpc_deployment
	for p in ${FOUNDATION_PLAYBOOKS}
	do
		if [[ ! -f /root/${p}.retry ]]
		then
			ap playbooks/setup/${p}.yml
		fi
		sleep 1

		count=0
		while [[ ${count} -lt ${RETRY} ]] && [[ -f /root/${p}.retry ]]
		do 
			let count=count+1
			ap playbooks/setup/${p}.yml --limit @/root/${p}.retry
			if [[ $? -eq 0 ]]; then break; fi

			if [[ ${count} -eq ${RETRY} ]]
			then
				echo "Exiting on ${p}."
				exit 1
			fi
		done
	done
}


install_infra_playbooks() {
	cd ~/ansible-lxc-rpc/rpc_deployment
	for p in ${INFRA_PLAYBOOKS}
	do
		if [[ ! -f /root/${p}.retry ]]
		then
			ap -vvv playbooks/infrastructure/${p}.yml
		fi
		sleep 1

		count=0
		while [[ ${count} -lt ${RETRY} ]] && [[ -f /root/${p}.retry ]]
		do 
			let count=count+1
			ap -vvv playbooks/infrastructure/${p}.yml --limit @/root/${p}.retry
			if [[ $? -eq 0 ]]; then break; fi

			if [[ ${count} -eq ${RETRY} ]]
			then
				echo "Exiting on ${p}."
				exit 1
			fi
		done
	done
}

check_galera() {
	# MySQL Test
	mysql -uroot -psecrete -h 192.168.1.107 -e 'show status;'
	STATUS=$?
	if [[ $STATUS != 0 ]]
	then
		echo "Check MariaDB/Galera. Unable to connect."
		exit 1
	fi
}

install_openstack_playbooks() {
	cd ~/ansible-lxc-rpc/rpc_deployment
	for p in ${OPENSTACK_PLAYBOOKS}
	do
		if [[ ! -f /root/${p}.retry ]]
		then
			ap playbooks/openstack/${p}.yml
		fi
		sleep 1

		count=0
		while [[ ${count} -lt ${RETRY} ]] && [[ -f /root/${p}.retry ]]
		do 
			let count=count+1
			ap -vvv playbooks/openstack/${p}.yml --limit @/root/${p}.retry
			if [[ $? -eq 0 ]]; then break; fi

			if [[ ${count} -eq ${RETRY} ]]
			then
				echo "Exiting on ${p}."
				exit 1
			fi
		done
	done
}

fixup_flat_networking() {
	for a in {1..3}; do ssh -n openstack${a} "sed -i 's/vlan:br-vlan/vlan:eth11/g' /etc/neutron/plugins/ml2/ml2_conf.ini; restart neutron-linuxbridge-agent"; done
}

#reset_environment
get_playbooks
install_pip
install_ansible
#configure_deployment
#pre_deploy_containers
#install_foundation_playbooks
#install_infra_playbooks
#check_galera
#install_openstack_playbooks
#fixup_flat_networking

# List Inventory Contents
#~/ansible-lxc-rpc/scripts/inventory-manage.py -f /etc/rpc_deploy/rpc_inventory.json --list-host
