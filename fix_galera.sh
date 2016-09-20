sed -i 's/galera_wsrep_slave_threads.*/galera_wsrep_slave_threads: 2/g' /opt/openstack-ansible/playbooks/roles/galera_server/defaults/main.yml
sed -i 's/all_calculated_max_connections.append.*/all_calculated_max_connections.append(1 * 100) %}/' /opt/openstack-ansible/playbooks/roles/galera_server/templates/my.cnf.j2
sed -i 's/galera_innodb_buffer_pool_size.*/galera_innodb_buffer_pool_size: 1024M/g' /opt/openstack-ansible/playbooks/roles/galera_server/defaults/main.yml
