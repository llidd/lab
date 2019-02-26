#!/bin/bash
if [[ $EUID > 0 ]]; then 
  echo "Please run as root/sudo"
  exit 1
else
  systemctl stop NetworkManager
  systemctl disable NetworkManager
  systemctl stop firewalld
  systemctl disable firewalld
  systemctl restart network
  setenforce 0
  sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
  yum install -y centos-release-openstack-rocky
  yum update -y
  yum install -y openstack-packstack
  packstack --gen-answer-file=answer.cfg
fi
