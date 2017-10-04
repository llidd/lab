#!/usr/bin/env bash
yum -y install nfs-utils centos-release-openstack-ocata epel-release 
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-OpenStack-ocata.repo
yum -y install qemu-kvm libvirt virt-install bridge-utils libguestfs-tools
yum --enablerepo=epel -y install rabbitmq-server memcached
yum --enablerepo=centos-openstack-ocata,epel -y install openstack-keystone openstack-utils python-openstackclient httpd mod_wsgi
yum --enablerepo=centos-openstack-ocata,epel -y install openstack-glance
yum --enablerepo=centos-openstack-ocata,epel -y install openstack-nova openstack-nova-compute
yum --enablerepo=centos-openstack-ocata,epel -y install openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch
yum --enablerepo=centos-openstack-ocata,epel -y install openstack-dashboard
yum --enablerepo=centos-openstack-ocata,epel -y install openstack-cinder
