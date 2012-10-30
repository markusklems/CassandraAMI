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
# Start cassandra and opscenter.
sudo service cassandra restart
sudo service opscenterd restart