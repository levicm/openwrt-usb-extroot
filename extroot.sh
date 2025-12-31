#!/bin/bash

echo "*** Extroot Setup Script ***"
echo "This script will set up extroot on /dev/sda1 for your OpenWrt device."
echo "Powered By Levi Mota"

# Install required packages
opkg update
opkg install kmod-usb-storage kmod-fs-ext4 block-mount 


DEVICE="/dev/sda1"

# Test if device is present
echo "Checking if $DEVICE is present..." 
if [ ! -b ${DEVICE} ]; then
    echo "Device $DEVICE not found! Please connect the storage device and try again."
    exit 1
fi

# Configuring extroot to use /dev/sda1 as the new overlay
echo "Getting UUID of $DEVICE..."
eval $(block info ${DEVICE} | grep -o -e "UUID=\S*")

echo "Configuring extroot to use $DEVICE as the new overlay..."
uci -q delete fstab.overlay
uci set fstab.overlay="mount"
uci set fstab.overlay.uuid="${UUID}"
uci set fstab.overlay.target="/overlay"
uci commit fstab

# Transfer existing overlay data to the new overlay
echo "Transferring existing overlay data to the new overlay on $DEVICE..."
mount ${DEVICE} /mnt

tar -C /overlay -cvf - . | tar -C /mnt -xf -

# Until here the new overlay is ready. Now we will configure a mount entry for the rwm partition.

# Configure a mount entry for the original overlay.
# This will allow you to access the rootfs_data / ubifs partition and customize the extroot configuration /rwm/upper/etc/config/fstab.
FLASH_DEVICE="$(sed -n -e "/\s\/overlay\s.*$/s///p" /etc/mtab)"

uci -q delete fstab.rwm
uci set fstab.rwm="mount"
uci set fstab.rwm.device="${FLASH_DEVICE}"
uci set fstab.rwm.target="/rwm"
uci commit fstab

# All done!

echo -e "All done! Your router will be rebooted in 5 seconds..."

sleep 5

reboot