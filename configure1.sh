#!/bin/sh -ex
################################
### NO WARRANTIES WHATSOEVER ###
################################
export DEBIAN_FRONTEND=noninteractive
# Retrieve the latest version of the scripts.
(cd /home/ubuntu/cassandra_ami; git pull)
sleep 2
sudo chmod +x /home/ubuntu/cassandra_ami/configure2.sh
sudo chmod +x /home/ubuntu/cassandra_ami/configure_devices.sh
sudo chmod +x /home/ubuntu/cassandra_ami/configure_devices_as_RAID0.sh
sudo chmod +x /home/ubuntu/cassandra_ami/configure_devices_as_logical_volumes.sh
# Now call the other scripts
sudo sh /home/ubuntu/cassandra_ami/configure2.sh