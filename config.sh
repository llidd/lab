#!/bin/bash
if [[ $EUID > 0 ]]; then 
  echo "Please run as root/sudo"
  exit 1
else
  sed -i 's/CONFIG_SWIFT_INSTALL=y/CONFIG_SWIFT_INSTALL=n/g' answer.cfg
  sed -i 's/CONFIG_CEILOMETER_INSTALL=y/CONFIG_CEILOMETER_INSTALL=n/g' answer.cfg
fi
