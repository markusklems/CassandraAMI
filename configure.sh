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

sudo apt-get update -y

# Retrieve the latest version of the scripts.
(cd "$HOME/cassandra_ami"; git pull)
# Move the priam libs to where they belong.
sudo cp "$HOME/cassandra_ami/priam.jar" /usr/share/cassandra/lib/.
sudo cp "$HOME/cassandra_ami/priam-web.war" /var/lib/tomcat7/webapps/.

sudo rm /etc/security/limits.conf
cat >"$HOME/limits.conf" <<END_OF_FILE
* soft nofile 32768
* hard nofile 32768
root soft nofile 32768
root hard nofile 32768
* soft memlock unlimited
* hard memlock unlimited
root soft memlock unlimited
root hard memlock unlimited
* soft as unlimited
* hard as unlimited
root soft as unlimited
root hard as unlimited
END_OF_FILE

sudo mv "$HOME/limits.conf" /etc/security/limits.conf
sudo chown root:root /etc/security/limits.conf
sudo chmod 755 /etc/security/limits.conf

sudo chown -hR ubuntu:ubuntu "$HOME"

# Mount devices
sudo mount -a

# Disable swap
sudo swapoff --all
	
# Setup the motd
sudo rm -rf /etc/motd
sudo touch /etc/motd

# Install DataStax Cassandra community edition
sudo apt-get install -y python-cql dsc1.1
sudo service cassandra stop
	
# Remove and recreate cassandra directories.
sudo rm -rf /var/lib/cassandra
sudo rm -rf /var/log/cassandra
sudo mkdir -p /var/lib/cassandra
sudo mkdir -p /var/log/cassandra
sudo chown -R cassandra:cassandra /var/lib/cassandra
sudo chown -R cassandra:cassandra /var/log/cassandra
	
# Priam settings
sudo sed -i -e "s|classname=\"org.apache.cassandra.thrift.CassandraDaemon\"|classname=\"com.netflix.priam.cassandra.NFThinCassandraDaemon\"|" /usr/sbin/cassandra
sudo sed -i -e "s|org.apache.cassandra.thrift.CassandraDaemon|com.netflix.priam.cassandra.NFThinCassandraDaemon|" /etc/init.d/cassandra

# Install OpsCenter
sudo apt-get -y install opscenter-free
sudo service opscenterd stop
	
# Setup of devices.
sudo sh configure_devices.sh 