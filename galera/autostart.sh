#!/usr/bin/env bash
sudo iptables -I INPUT 1 -p tcp --dport 3306 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 4567 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 4568 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 4444 -j ACCEPT
sudo iptables -I INPUT 1 -p udp --dport 4567 -j ACCEPT
sed -i 's,^\(safe_to_bootstrap:\).*,\1'1',g' /home/galera/data/grastate.dat
docker start node0
sleep 100 && docker exec -ti node0 mysql -p -e 'SET GLOBAL wsrep_provider_options="pc.weight=2";

