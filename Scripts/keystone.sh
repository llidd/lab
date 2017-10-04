#!/usr/bin/env bash
export controller1=10.10.7.1
su -s /bin/bash keystone -c "keystone-manage db_sync"
keystone-manage bootstrap --bootstrap-password adminpassword \
--bootstrap-admin-url http://$controller1:35357/v3/ \
--bootstrap-internal-url http://$controller1:35357/v3/ \
--bootstrap-public-url http://$controller1:5000/v3/ \
--bootstrap-region-id RegionOne
systemctl restart httpd
systemctl enable httpd
