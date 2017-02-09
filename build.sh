#!/bin/bash


## check sudo/root
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root"; exit 1; fi


## build all
(cd kernel && bash copy_kernel.sh)
(cd initrd && bash build_initrd.sh)
(cd rootfs && bash build_rootfs.sh)
(cd recovery && bash build_recovery.sh)
