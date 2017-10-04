#!/usr/bin/env bash
docker exec -ti node0 mysql -e 'SET GLOBAL wsrep_provider_options="pc.weight=2";'
docker exec -ti node0 mysql -e "CREATE USER 'root'@'%' IDENTIFIED BY '615243';"
docker exec -ti node0 mysql -e "GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;"
docker exec -ti node0 mysql --e "FLUSH PRIVILEGES;" 
