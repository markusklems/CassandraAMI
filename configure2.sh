#!/bin/sh -ex
################################
### NO WARRANTIES WHATSOEVER ###
################################
export DEBIAN_FRONTEND=noninteractive

echo "deb http://debian.datastax.com/community stable main" | sudo -E tee -a /etc/apt/sources.list
curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
curl -s http://opscenter.datastax.com/debian/repo_key | sudo apt-key add -
curl -s http://installer.datastax.com/downloads/ubuntuarchive.repo_key | sudo apt-key add -
sudo apt-get update -y

sudo rm /etc/security/limits.conf
cat >/home/ubuntu/limits.conf <<END_OF_FILE
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

sudo mv /home/ubuntu/limits.conf /etc/security/limits.conf
sudo chown root:root /etc/security/limits.conf
sudo chmod 755 /etc/security/limits.conf

sudo chown -hR ubuntu:ubuntu /home/ubuntu

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
	
# Priam settings
sudo sed -i -e "s|classname=\"org.apache.cassandra.thrift.CassandraDaemon\"|classname=\"com.netflix.priam.cassandra.NFThinCassandraDaemon\"|" /usr/sbin/cassandra
sudo sed -i -e "s|org.apache.cassandra.thrift.CassandraDaemon|com.netflix.priam.cassandra.NFThinCassandraDaemon|" /etc/init.d/cassandra
# Move the priam libs to where they belong.
sudo cp /home/ubuntu/cassandra_ami/priam.jar /usr/share/cassandra/lib/.
sudo cp /home/ubuntu/cassandra_ami/priam-web.war /var/lib/tomcat7/webapps/.

# Install OpsCenter
sudo apt-get -y install opscenter-free
sudo service opscenterd stop
	
# Setup of devices.
sudo sh /home/ubuntu/cassandra_ami/configure_devices.sh
# Logical volumes etc
	
# Remove and recreate cassandra directories.
C_LOG_DIR=/var/log/cassandra
C_LIB_DIR=/var/lib/cassandra
sudo rm -rf $C_LIB_DIR
sudo rm -rf $C_LOG_DIR
sudo mkdir -p $C_LIB_DIR
sudo mkdir -p $C_LOG_DIR
sudo chown -R cassandra:cassandra $C_LIB_DIR
sudo chown -R cassandra:cassandra $C_LOG_DIR
# Create links to cassandra log and lib dirs.
ln -s /mnt/cassandra/logs $C_LOG_DIR
ln -s /mnt/cassandra/lib $C_LIB_DIR