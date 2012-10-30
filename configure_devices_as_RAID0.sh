#!/bin/sh -ex
## Setup of devices as RAID0 array.
## By Markus Klems (2012).
## Tested with Ubuntu 11.10 (ami-cdc072a4).
################################
### NO WARRANTIES WHATSOEVER ###
################################
export DEBIAN_FRONTEND=noninteractive

while getopts m:p:d: option
do
	case "${option}"
		in
		    m) MULTIDISK=${OPTARG};;
			p) MOUNTPOINT=${OPTARG};;
			d) DEVICES=${OPTARG};;
	esac
done

echo "Create RAID0 setup from devices: $DEVICES"

count=0
for device in $DEVICES; do
	count=$(($count + 1))
	echo "Device number $count"
	echo "Confirming device $device is not mounted."
	sudo umount $device
	#Clear 'invalid flag 0x0000 of partition table 4' by issuing a write, then running fdisk on each device
	echo "Partition device $device"
	echo 'w' | sudo fdisk -c -u $device
	# New partition (n), primary partition (p), partition number (1),
	# First sector (default), Last sector (default), type (t), Linux RAID (fd), write (w)
	#echo "n\np\n1\n\n\nt\nfd\nw" | sudo fdisk -c -u $device
	echo "n
	p
	1


	t
	fd
	w" | sudo fdisk -c -u $device
done

sleep 3

raiddevs=""
partitionnumber="1"
for device in $DEVICES; do
	raiddevs="$device$partitionnumber $raiddevs"
done
#remove last character
raiddevs=${raiddevs%?}

echo "Creating RAID0 array of $count devices $raiddevs at $MULTIDISK"
sudo mdadm --create $MULTIDISK --chunk=256 --level=0 --raid-devices=$count $raiddevs
echo DEVICE $raiddevs | sudo tee /etc/mdadm/mdadm.conf
sleep 5
mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sleep 10
blockdev --setra 512 $MULTIDISK
sleep 10
# Make file system
# script for calculating the optimal stride/stripe geometry?
#sudo mkfs.ext4 $MULTIDISK -b 4096 -E stride=128,stripe-width=256
sudo mkfs.ext4 $MULTIDISK
echo "$MULTIDISK\t$MOUNTPOINT\text4\tdefaults,nobootwait,noatime\t0\t0" | sudo tee -a /etc/fstab
sudo mkdir $MOUNTPOINT
sudo mount -a

echo "Show RAID0 details:"
cat /proc/mdstat
echo "15000" > /proc/sys/dev/raid/speed_limit_min
sudo mdadm --detail $MULTIDISK
	
