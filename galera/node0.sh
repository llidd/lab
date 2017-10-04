#!/usr/bin/env bash
mkdir data
sudo iptables -I INPUT 1 -p tcp --dport 3306 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 4567 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 4568 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 4444 -j ACCEPT
sudo iptables -I INPUT 1 -p udp --dport 4567 -j ACCEPT
docker run -d --name node0 --net host -h node0 -v /home/galera/data:/var/lib/mysql:Z -p 3306:3306 -p 4567:4567/udp -p 4567-4568:4567-4568 -p 4444:4444 giggsoff/galera --wsrep-cluster-name=local-test --wsrep-cluster-address=gcomm:// --wsrep-node-address=10.10.7.1
