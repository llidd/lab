#!/usr/bin/env bash
systemctl start memcached
systemctl enable memcached
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
chown nova. /var/log/nova/nova-placement-api.log
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq
sudo iptables -I INPUT 1 -p tcp --dport 4369 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 25672 -j ACCEPT
systemctl start rabbitmq-server
