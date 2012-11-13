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
# Tomcat user must be allowed to start cassandra.
# TODO: fine-tune this:
echo "tomcat7 ALL = NOPASSWD: ALL" | sudo tee -a /etc/sudoers
# Add tomcat7 user to cassandra group
# sudo usermod -g cassandra tomcat7

# Install OpsCenter
sudo apt-get -y install opscenter-free
sudo service opscenterd stop
	
# Setup of devices.
umount /mnt
sleep 2
# Parameters:
MULTIDISK="/dev/md0"
sudo sh /home/ubuntu/cassandra_ami/configure_devices_as_RAID0.sh -m $MULTIDISK -d "/dev/xvdb /dev/xvdc"
# Logical volumes etc
sudo sh /home/ubuntu/cassandra_ami/configure_devices_as_logical_volume.sh $MULTIDISK

# Remove and recreate cassandra directories.
C_LOG_DIR=/var/log/cassandra
C_LIB_DIR=/var/lib/cassandra
LV_LOG_DIR="/mnt$C_LOG_DIR"
LV_LIB_DIR="/mnt$C_LIB_DIR"
sudo rm -rf $C_LIB_DIR
sudo rm -rf $C_LOG_DIR
#sudo mkdir -p $C_LIB_DIR
#sudo mkdir -p $C_LOG_DIR
sudo mkdir -p $LV_LOG_DIR
sudo mkdir -p $LV_LIB_DIR
# Create links to cassandra log and lib dirs.
sudo ln -s $LV_LOG_DIR /var/log
sudo ln -s $LV_LIB_DIR /var/lib
# Make data, commitlog, and cache dirs.
sudo mkdir -p $LV_LIB_DIR/data
sudo mkdir -p $LV_LIB_DIR/commitlog
sudo mkdir -p $LV_LIB_DIR/saved_caches
# Set access rights.
sudo chown -R cassandra:cassandra $C_LIB_DIR
sudo chown -R cassandra:cassandra $C_LOG_DIR
sudo chown -R cassandra:cassandra $LV_LIB_DIR
sudo chown -R cassandra:cassandra $LV_LOG_DIR

# Move the priam lib to where it belongs.
sudo cp /home/ubuntu/cassandra_ami/priam.jar /usr/share/cassandra/lib/.
sudo chmod -R 777 /etc/cassandra

# I changed Priam, instead of doing this:
# Copy the cassandra conf to where priam expects it:
#sudo mkdir -p /tmp/cassandraconf
#sudo cp /etc/cassandra/* /tmp/cassandraconf/.
#sudo mkdir -p /etc/cassandra/conf
#sudo cp /tmp/cassandraconf/* /etc/cassandra/conf/.
#sudo rm -rf /tmp/cassandraconf
#sudo chmod -R 777 /etc/cassandra/conf/
	
# Network settings:
# replace 127.0.0.1 with EC2 private IP
privateip=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
sudo sed -i -e "s|127.0.0.1 localhost|$privateip localhost|" /etc/hosts
# public hostname and ip
#publichostname=`curl -s http://169.254.169.254/latest/meta-data/public-hostname`
#publicip=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4` 
	
# Deploy the priam-web war file to the Tomcat container.
sudo cp /home/ubuntu/cassandra_ami/Priam.war /var/lib/tomcat7/webapps/.
# Start Tomcat/Priam-Cassandra + opscenter
sudo /home/ubuntu/cassandra_ami/start.sh
	
# Wait for services to start.
sleep 120

# quick fix so tomcat7 can read cassandra/data/system dir
# not secure, should refactor this later:
sudo chmod -R 777 $C_LIB_DIR
sudo chmod -R 777 $C_LOG_DIR
sudo chmod -R 777 $LV_LIB_DIR
sudo chmod -R 777 $LV_LOG_DIR

sleep 30

# Create ycsb table. Concurrent execution should be no issue (?)
sudo /home/ubuntu/cassandra_ami/configure_ycsb.sh $privateip