#!/bin/bash
if [[ $EUID > 0 ]]; then 
  echo "Please run as root/sudo"
  exit 1
else
  #Give more swap space for install if it needed
  mem_number=$(free | grep -v 'used' | awk '{sum+=$2} END {print sum}')
  let "minimum_required= 12*1024*1024" # get 12 gb in byte (for me it needed)
  if [ $mem_number -lt $minimum_required ]; then
    let "new_space_mb=(minimum_required-$mem_number)/1024"
    dd if=/dev/zero of=/swapfile bs=1M count=$new_space_mb
    mkswap /swapfile 
    chmod 600 /swapfile
    swapon /swapfile
    echo 'Swap successfully allocated to 12 GB'
  fi
fi
