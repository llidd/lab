#!/usr/bin/env bash
source /home/keystonerc
export controller1=10.10.7.1
openstack project create --domain default --description "Service Project" service

openstack user create --domain default --project service --password servicepassword glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image service" image
openstack endpoint create --region RegionOne image public http://$controller1:9292
openstack endpoint create --region RegionOne image internal http://$contoller1:9292
openstack endpoint create --region RegionOne image admin http://$controller1:9292

openstack user create --domain default --project service --password servicepassword nova
openstack role add --project service --user nova admin
openstack user create --domain default --project service --password servicepassword placement
openstack role add --project service --user placement admin
openstack service create --name nova --description "OpenStack Compute service" compute
openstack service create --name placement --description "OpenStack Compute Placement service" placement
openstack endpoint create --region RegionOne compute public http://$controller1:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://$controller1:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://$controller1:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne placement public http://$controller1:8778
openstack endpoint create --region RegionOne placement internal http://$controller1:8778
openstack endpoint create --region RegionOne placement admin http://$controller1:8778

openstack user create --domain default --project service --password servicepassword neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking service" network
openstack endpoint create --region RegionOne network public http://$controller1:9696
openstack endpoint create --region RegionOne network internal http://$controller1:9696
openstack endpoint create --region RegionOne network admin http://$controller1:9696

openstack user create --domain default --project service --password servicepassword cinder
openstack role add --project service --user cinder admin
openstack service create --name cinder --description "OpenStack Block Storage" volume
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
openstack endpoint create --region RegionOne volume public http://$controller1:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume internal http://$controller1:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume admin http://$controller1:8776/v1/%\(tenant_id\)s 
openstack endpoint create --region RegionOne volumev2 public http://$controller1:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://$controller1:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://$controller1:8776/v2/%\(tenant_id\)s

