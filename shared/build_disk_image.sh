#!/bin/bash

# create empty image 500M
dd if=/dev/zero of=rootfs.img bs=1 count=0 seek=500M

# format image
mkfs.ext4 -b 4096 -F rootfs.img

# copy rootfs to image
sudo mount -o loop rootfs.img /mnt
sudo cp -a rootfs/. /mnt/
sudo umount /mnt

# copy kernel
cp rootfs/boot/vmlinuz* .
ln -s vmlinuz-* vmlinuz