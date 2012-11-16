#!/bin/bash
## Start Apache Cassandra and DataStax OpsCenter.
## By Markus Klems (2012).
## Tested with Ubuntu 11.10 (ami-cdc072a4).
################################
### NO WARRANTIES WHATSOEVER ###
################################
export DEBIAN_FRONTEND=noninteractive

# We need Tomcat for priam-web.
sudo service tomcat7 restart
# Start opscenter. Cassandra is started by priam.
#sudo service cassandra restart
sudo service opscenterd restart
	
# Wait for services to start.
#sleep 120

# quick fix so tomcat7 can read cassandra/data/system dir
# not secure, should refactor this later:
#sudo chmod -R 777 $C_LIB_DIR
#sudo chmod -R 777 $C_LOG_DIR
#sudo chmod -R 777 $LV_LIB_DIR
#sudo chmod -R 777 $LV_LOG_DIR