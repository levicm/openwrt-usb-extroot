#!/bin/bash

echo "*** Swap to sda2 Script ***"
echo "This script will set up swap on /dev/sda2 for your OpenWrt device."
echo "Powered By Levi Mota"

# Install required packages
opkg update
opkg install kmod-usb-storage kmod-fs-ext4 block-mount 


DEVICE="/dev/sda2" 

# Test if device is present
echo "Checking if $DEVICE is present..." 
if [ ! -b ${DEVICE} ]; then
    echo "Device $DEVICE not found! Please connect the storage device and try again."
    exit 1
fi

echo "Checking if $DEVICE is swap..." 
INFO=$(block info $DEVICE 2>/dev/null) 
TYPE=$(echo "$INFO" | grep -o 'TYPE="[^"]*"' | cut -d'"' -f2) 
UUID=$(echo "$INFO" | grep -o 'UUID="[^"]*"' | cut -d'"' -f2)

if [ ! "$TYPE" = "swap" ]; then 
    echo "❌ $DEVICE is not a swap partition. Exiting script."
    exit 1
fi

echo "✅ $DEVICE is a swap partition." 
# Activate it manually now 
swapon $DEVICE 2>/dev/null 
if [ $? -eq 0 ]; then
    echo "Swap activated successfully."
else
    echo "Failed to activate swap."
    exit 1
fi

# Configure in fstab via UCI 
echo "Configuring swap in fstab to be persistent..."
uci -q delete fstab.swap
uci set fstab.swap="swap"
uci set fstab.swap.uuid="$UUID"
uci set fstab.swap.enabled='1'
uci commit fstab

echo "All done! Current status:"
cat /proc/swaps
