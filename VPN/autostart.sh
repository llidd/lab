#!/usr/bin/env bash
/sbin/modprobe dummy
sleep 2
sh /home/VPN/brvpn1
systemctl restart docker
sleep 10 && docker start VPNServer

