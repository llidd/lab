#!/bin/bash
if [[ $EUID > 0 ]]; then 
  echo "Please run as root/sudo"
  exit 1
else
  sed -i 's/CONFIG_SWIFT_INSTALL=y/CONFIG_SWIFT_INSTALL=n/g' answer.cfg
  sed -i 's/CONFIG_CEILOMETER_INSTALL=y/CONFIG_CEILOMETER_INSTALL=n/g' answer.cfg
  sed -i 's/CONFIG_AODH_INSTALL=y/CONFIG_AODH_INSTALL=n/g' answer.cfg
  sed -i 's/CONFIG_CINDER_INSTALL=y/CONFIG_CINDER_INSTALL=n/g' answer.cfg
  sed -i 's/CONFIG_NEUTRON_METERING_AGENT_INSTALL=y/CONFIG_NEUTRON_METERING_AGENT_INSTALL=n/g' answer.cfg
  sed -i 's/CONFIG_PROVISION_DEMO=y/CONFIG_PROVISION_DEMO=n/g' answer.cfg
  sed -i 's/CONFIG_SERVICE_WORKERS=%{::processorcount}/CONFIG_SERVICE_WORKERS=1/g' answer.cfg
  INTERFACE=`ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//"`
  sed -i 's/CONFIG_NEUTRON_OVS_BRIDGE_IFACES=$/CONFIG_NEUTRON_OVS_BRIDGE_IFACES=br-ex:'"$INTERFACE"'/g' answer.cfg
fi
