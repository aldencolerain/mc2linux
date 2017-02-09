#!/bin/bash

## settings
USB=/media/jackson/REC


## check sudo/root
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root"; exit 1; fi


## load onto usb
rm -r $USB/*
mkdir -p $USB/boot
cp build/uImage $USB/boot
cp build/uRamdiskRecovery $USB/boot/uRamdisk
cp build/uRamdiskStandard $USB/boot/uRamdiskStandard
cp build/rootfs.tar.gz $USB/