#!/bin/bash
## Configure EC2 ephemeral and ebs devices.
## By Markus Klems (2012).
## Tested with Ubuntu 11.10 (ami-cdc072a4) m1.large.
################################
### NO WARRANTIES WHATSOEVER ###
################################
export DEBIAN_FRONTEND=noninteractive

# Unmount /dev/xvdb from /mnt
sudo umount /mnt

cd "$HOME/cassandra_ami"
sudo sh configure_devices_as_RAID0.sh -m /dev/md0 -p /raid0 -d "/dev/xvdb /dev/xvdc"
