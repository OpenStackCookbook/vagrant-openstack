        # Add haproxy user to be accessed from logging
        # Add root user with password from user_secrets to be accessed from logging with privileges

        G1=$(awk '/controller-01_galera/ {print $1}' /etc/hosts)
        PASS=$(awk '/galera_root_password/ {print $2}' /etc/openstack_deploy/user_secrets.yml)
        ssh ${G1} "mysql -u root -h localhost -e \"GRANT ALL ON *.* to haproxy@'logging';\""
        ssh ${G1} "mysql -u root -h localhost -e \"GRANT ALL ON *.* to root@'logging' IDENTIFIED BY '${PASS}' WITH GRANT OPTION;\""

        apt-get -y install mariadb-client
        # MySQL Test
        PASS=$(awk '/galera_root_password/ {print $2}' /etc/openstack_deploy/user_secrets.yml)
        mysql -uroot -p${PASS} -h 172.29.236.10 -e 'show status;'
        STATUS=$?
        if [[ $STATUS != 0 ]]
        then
                echo "Check MariaDB/Galera. Unable to connect."
                exit 1
        fi
