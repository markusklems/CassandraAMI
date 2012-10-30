#!/bin/sh -ex
## Configure EC2 ephemeral and ebs devices.
## By Markus Klems (2012).
## Tested with Ubuntu 11.10 (ami-cdc072a4) m1.large.
################################
### NO WARRANTIES WHATSOEVER ###
################################
export DEBIAN_FRONTEND=noninteractive

umount /mnt

sleep 2

# Parameters:
# -m: multidisk
# -p: mountpoint
# -d: string of devices, separated by blank character
sudo sh "$HOME/cassandra_ami/configure_devices_as_RAID0.sh" -m /dev/md0 -p /raid0 -d "/dev/xvdb /dev/xvdc"