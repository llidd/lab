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
  systemctl start ksmtuned
  systemctl enable ksmtuned
  yum install -y centos-release-openstack-rocky
  yum update -y
  yum install -y openstack-packstack
  packstack --gen-answer-file=answer.cfg
  
  #Give more swap space for install if it needed
  mem_number=$(free | grep -v 'used' | awk '{sum+=$2} END {print sum}') #get current Memory size + Swap size in byte
  let "minimum_required= 12*1024*1024" # get 12 gb in byte (for me it needed) #get minimum required Memory for script
  if [ $mem_number -lt $minimum_required ]; then # if we need more space
    let "new_space_mb=(minimum_required-$mem_number)/1024" #calculate how many space
    dd if=/dev/zero of=/swapfile bs=1M count=$new_space_mb #give space
    mkswap /swapfile #make new swap
    chmod 600 /swapfile
    swapon /swapfile #connect swap
    echo 'Swap successfully allocated to 12 GB'
  fi
fi
