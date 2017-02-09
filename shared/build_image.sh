#!/bin/bash
# Usage: source_directory output_image_file_path


## check sudo/root
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root"; exit 1; fi


## build image

# build initrd system archive"
cd $1
find . | cpio -o -H newc | gzip > ../initramfs.archive.gz

# create u-boot system image from archive
cd ..
mkimage -A arm -O linux -T ramdisk -C gzip -a 0x00e00000 -n Ramdisk -d initramfs.archive.gz $2

# clean up
rm initramfs.archive.gz