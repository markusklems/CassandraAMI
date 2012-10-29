#!/bin/sh

### BEGIN INIT INFO
# Provides:
# Required-Start:    $remote_fs $syslog
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Start AMI Configurations on boot.
# Description:       Enables AMI Configurations on startup.
### END INIT INFO

# Make sure variables get set
export JAVA_HOME=/opt/java/64/jdk1.6.0_31

# Setup system properties
sudo su -c 'ulimit -n 32768'
echo 1 | sudo tee /proc/sys/vm/overcommit_memory

# Clear old ami.log
echo "\n======================================================\n" >> ami.log
cd "$HOME/cassandra_ami"
git pull