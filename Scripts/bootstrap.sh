#!/usr/bin/env bash
export controller1=10.10.7.1
su -s /bin/bash glance -c "glance-manage db_sync"
su -s /bin/bash nova -c "nova-manage api_db sync"
su -s /bin/bash nova -c "nova-manage cell_v2 map_cell0 \
--database_connection mysql+pymysql://nova:password@current/nova_cell0"
su -s /bin/bash nova -c "nova-manage db sync"
su -s /bin/bash nova -c "nova-manage cell_v2 create_cell --name cell1 \
--database_connection mysql+pymysql://nova:password@current/nova \
--transport-url rabbit://openstack:password@$controller1:5672"
su -s /bin/bash neutron -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head"
su -s /bin/bash cinder -c "cinder-manage db sync"
