#!/usr/bin/env bash
docker exec -ti node0 mysql -e 'SET GLOBAL wsrep_provider_options="pc.weight=2";'
docker exec -ti node0 mysql -e "CREATE USER test@'node0' IDENTIFIED BY '615243';"
docker exec -ti node0 mysql -e "GRANT ALL ON *.* TO test@'node0' WITH GRANT OPTION;"
docker exec -ti node0 mysql -e "FLUSH PRIVILEGES;"
