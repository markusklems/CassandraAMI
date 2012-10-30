#!/bin/sh -e
## Setup of devices as logical volume.
## By Markus Klems (2012).
## Tested with Ubuntu 11.10 (ami-cdc072a4).
################################
### NO WARRANTIES WHATSOEVER ###
################################
export DEBIAN_FRONTEND=noninteractive

devices=$@
	
for device in devices; do
	echo "Confirming device $device is not mounted."
	sudo umount $device
	#Clear 'invalid flag 0x0000 of partition table 4' by issuing a write, then running fdisk on each device
	echo "Partition device $device"
	echo 'w' | sudo fdisk -c -u $device
	# New partition (n), primary partition (p), partition number (1),
	# First sector (default), Last sector (default), type (t), Linux RAID (fd), write (w)
	echo 'n\np\n1\n\n\nt\nfd\nw' | sudo fdisk -c -u
done

# Create physical volumes.
sudo pvcreate /dev/xvdb1
sudo pvcreate /dev/xvdc1
# Create volume group.
sudo vgcreate vgcassandra /dev/xvdb1 /dev/xvdc1
# Create logical volumes.
sudo lvcreate -l +100%FREE -n lvcassandra vgcassandra
# Create file system.
sudo mkfs.ext4 /dev/vgcassandra/lvcassandra
	
sudo chown -hR cassandra:cassandra /dev/xvdb1
sudo chown -hR cassandra:cassandra /dev/xvdc1
sudo chown -hR cassandra:cassandra /mnt/vgcassandra/lvcassandra