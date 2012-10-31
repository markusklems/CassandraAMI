#!/bin/sh -ex
## Setup of devices as logical volume.
## By Markus Klems (2012).
## Tested with Ubuntu 11.10 (ami-cdc072a4).
################################
### NO WARRANTIES WHATSOEVER ###
################################
export DEBIAN_FRONTEND=noninteractive

devices=$@

alldevices=""
# Create physical volumes.
for device in $devices; do
	sudo pvcreate $device
	alldevices="$device $alldevices"
done
#remove last character
alldevices=${alldevices%?}
#sudo pvcreate /dev/xvdb1
#sudo pvcreate /dev/xvdc1
	
# Create volume group.
#sudo vgcreate vgcassandra /dev/xvdb1 /dev/xvdc1
sudo vgcreate vgcassandra $alldevices
# Create logical volumes.
sudo lvcreate -l +100%FREE -n lvcassandra vgcassandra
# Create file system.
sudo mkfs.ext4 /dev/vgcassandra/lvcassandra

# Mount
sudo mount -t ext4 -o noatime /dev/vgcassandra/lvcassandra /mnt

sudo chown -hR cassandra:cassandra /dev/vgcassandra/lvcassandra
sudo chown -hR cassandra:cassandra /mnt
	
# Done here. Show LV.
sudo lvdisplay