#!/usr/bin/env bash
systemctl start memcached
systemctl enable memcached
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
touch /var/log/nova/nova-placement-api.log
chown nova. /var/log/nova/nova-placement-api.log
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq
chown -R rabbitmq:rabbitmq /etc/rabbitmq
sudo iptables -I INPUT 1 -p tcp --dport 4369 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 25672 -j ACCEPT
systemctl start rabbitmq-server
setenforce 0
rabbitmqctl add_user openstack password 
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
