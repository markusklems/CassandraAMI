#!/bin/bash
## Start Apache Cassandra and DataStax OpsCenter.
## By Markus Klems (2012).
## Tested with Ubuntu 11.10 (ami-cdc072a4).
################################
### NO WARRANTIES WHATSOEVER ###
################################
export DEBIAN_FRONTEND=noninteractive

sudo service cassandra restart
sudo service opscenterd restart