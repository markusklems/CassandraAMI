#!/bin/bash
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
#gpg --keyserver pgp.mit.edu --recv-keys 40976EAF437D05B5
#gpg --export --armor 40976EAF437D05B5 | sudo apt-key add -
echo "deb http://debian.datastax.com/community stable main" | sudo -E tee -a /etc/apt/sources.list
curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
curl -s http://opscenter.datastax.com/debian/repo_key | sudo apt-key add -
curl -s http://installer.datastax.com/downloads/ubuntuarchive.repo_key | sudo apt-key add -
echo "deb http://archive.canonical.com/ oneiric partner" | sudo tee -a /etc/apt/sources.list.d/java.sources.list
sudo echo "sun-java6-bin shared/accepted-sun-dlj-v1-1 boolean true" | sudo debconf-set-selections
sudo apt-get -y install git
# remove openjdk
sudo apt-get purge -y openjdk-6-jre-lib
sudo apt-get purge -y openjdk-7-jre openjdk-7-jre-lib
sudo apt-get autoremove -y
sudo apt-get update -y

# Git these files on to the server's home directory
git config --global color.ui auto
git config --global color.diff auto
git config --global color.status auto
git clone git://github.com/markusklems/CassandraAMI.git cassandra_ami
cd cassandra_ami

# Install Java
target_java_dir='/opt/java/64'
sudo mkdir -p $target_java_dir
url=http://download.oracle.com/otn-pub/java/jdk/6u31-b04/jdk-6u31-linux-x64.bin
  
tmpdir=`sudo mktemp -d`
# Silent download without Oracle hassling us (hopefully).
sudo wget -c --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F" "$url" --output-document="$tmpdir/`basename $url`"

sudo chmod 777 $tmpdir
(cd $tmpdir; sudo sh `basename $url` -noregister)
sudo mkdir -p `dirname $target_java_dir`
(cd $tmpdir; sudo mv jdk1* $target_java_dir)
sudo rm -rf $tmpdir

# Setup java alternatives
update-alternatives --install /usr/bin/java java "$target_java_dir/jdk1.6.0_31/bin/java" 17000
update-alternatives --set java "$target_java_dir/jdk1.6.0_31/bin/java"

# Try to set JAVA_HOME in a number of commonly used locations
export JAVA_HOME="$target_java_dir/jdk1.6.0_31"
if [ -f /etc/profile ]; then
  echo export JAVA_HOME=$JAVA_HOME >> /etc/profile
fi
if [ -f /etc/bashrc ]; then
  echo export JAVA_HOME=$JAVA_HOME >> /etc/bashrc
fi
if [ -f ~root/.bashrc ]; then
  echo export JAVA_HOME=$JAVA_HOME >> ~root/.bashrc
fi
if [ -f /etc/skel/.bashrc ]; then
  echo export JAVA_HOME=$JAVA_HOME >> /etc/skel/.bashrc
fi

# fix 'too many open files' problem
echo "* soft nofile 32768" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 32768" | sudo tee -a /etc/security/limits.conf

sudo apt-get update -y
# Install packages
sudo apt-get -y install --fix-missing libjna-java htop emacs23-nox sysstat iftop binutils pssh pbzip2 zip unzip ruby openssl libopenssl-ruby curl maven2 ant liblzo2-dev ntp subversion python-pip tree unzip ruby xfsprogs
sudo apt-get -y install ca-certificates-java icedtea-6-jre-cacao java-common jsvc libavahi-client3 libavahi-common-data libavahi-common3 libcommons-daemon-java libcups2 libjna-java libjpeg62 liblcms1 libnspr4-0d libnss3-1d tzdata-java	

# LVM and RAID
sudo apt-get -y --no-install-recommends install mdadm lvm2 dmsetup reiserfsprogs xfsprogs

# Utility tools
sudo apt-get install -y s3cmd

# Priam dependencies
sudo apt-get install -y tomcat7
sudo service tomcat7 stop
	
sudo apt-get update -y

# Pre-install Cassandra dependencies for convenience.
cd $HOME
git clone https://github.com/apache/cassandra.git
cd cassandra
ant
cd $HOME
rm -rf cassandra

# Set the start script
sudo mv "$HOME/cassandra_ami/start_ami_script.sh" /etc/init.d/start-ami-script.sh
sudo chmod 755 /etc/init.d/start-ami-script.sh
sudo update-rc.d -f start-ami-script.sh start 99 2 3 4 5 .
	
sudo chmod +x "$HOME/cassandra_ami/configure1.sh"
	
# Installation done.
# Clean up.
sudo rm .ssh/authorized_keys
sudo rm -rf /etc/ssh/ssh_host_dsa_key*
sudo rm -rf /etc/ssh/ssh_host_key*
sudo rm -rf /etc/ssh/ssh_host_rsa_key*
sudo rm -rf /tmp/*
sudo rm -rf /tmp/.*
sudo chown -R ubuntu:ubuntu $HOME/.
sudo rm -rf "$HOME/.bash_history"
history -c