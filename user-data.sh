#!/bin/bash
# Launch this script as user data with your EC2 instance.

# Enter your aws credential properties.
# Use SSL for communication with AWS.
cat >/etc/awscredential.properties <<END_OF_FILE
AWSACCESSID=abc
AWSKEY=xyz
END_OF_FILE

# Launch the configuration script.
# This should be done only once in the instance life.
sudo sh "$HOME/cassandra_ami/configure.sh"