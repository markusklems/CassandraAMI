#!/bin/bash -e
## Install Apache Cassandra and dependencies.
## The scripts are based on a combination of the DataStax ComboAMI scripts,
## the whirr cassandra scripts and my own scripts.
## By Markus Klems (2012).
## Tested with Ubuntu 11.10 (ami-cdc072a4).
################################
### NO WARRANTIES WHATSOEVER ###
################################
export DEBIAN_FRONTEND=noninteractive
# Retrieve the latest version of the scripts.
(cd "$HOME/cassandra_ami"; git pull)
# Now call the other scripts
sudo sh "$HOME/cassandra_ami/configure2.sh"