#!/usr/bin/env bash
systemctl start openstack-glance-api openstack-glance-registry 
systemctl enable openstack-glance-api openstack-glance-registry 
systemctl restart httpd
systemctl enable httpd
systemctl start libvirtd
systemctl enable libvirtd
for service in api cert consoleauth conductor scheduler novncproxy compute; do
systemctl start openstack-nova-$service
systemctl enable openstack-nova-$service
done
su -s /bin/bash nova -c "nova-manage cell_v2 discover_hosts"
systemctl start openvswitch
systemctl enable openvswitch
ovs-vsctl add-br br-int
for service in server dhcp-agent l3-agent metadata-agent openvswitch-agent; do
systemctl start neutron-$service
systemctl enable neutron-$service
done
systemctl restart openstack-nova-api openstack-nova-compute
systemctl start rpcbind nfs-server 
systemctl enable rpcbind nfs-server 
systemctl start openstack-cinder-api openstack-cinder-scheduler openstack-cinder-volume
systemctl enable openstack-cinder-api openstack-cinder-scheduler openstack-cinder-volume
systemctl restart httpd
