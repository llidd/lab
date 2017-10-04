#!/usr/bin/env bash
ovs-vsctl add-br br-eth1
ovs-vsctl add-port br-eth1 dummy2
systemctl restart neutron-openvswitch-agent
source /home/keystonerc
projectID=`openstack project list | grep service | awk '{print $2}'`
openstack network create --project $projectID \
--share --provider-network-type flat --provider-physical-network physnet1 sharednet1
openstack subnet create subnet1 --network sharednet1 \
--project $projectID --subnet-range 10.10.7.0/24 \
--allocation-pool start=10.10.7.200,end=10.10.7.254 \
--gateway 10.10.7.1 --dns-nameserver 8.8.8.8
