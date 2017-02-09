#!/bin/ash

echo "WARNING!!!  This process will delete all data on your WD My Cloud!"

# confirmation
read -p "Are you sure you want to delete your entire drive and install debian? [Y/n]"
if [ "$REPLY" != "Y" ]; then exit; fi

# create partitions
parted --script /dev/sda mklabel gpt
parted -a optimal /dev/sda --script mkpart primary linux-swap 0% 1G
parted -a optimal /dev/sda --script mkpart primary ext4 4G 100%
parted -a optimal /dev/sda --script mkpart primary ext4 1G 4G
mkswap /dev/sda1
mkfs.ext4 -F /dev/sda2
mkfs.ext4 -F /dev/sda3

# mount usb drive (sdb)
mkdir -p /mnt/usb
mount /dev/sdb1 /mnt/usb

# mount root drive
mkdir -p /mnt/root
mount /dev/sda3 /mnt/root

# copy rootfs (kernel, initrd, debian)
mkdir -p /mnt/root/boot
cp /mnt/usb/boot/uImage /mnt/root/boot/uImage
cp /mnt/usb/boot/uRamdiskStandard /mnt/root/boot/uRamdisk
tar -xzf /mnt/usb/rootfs.tar.gz  -C /mnt/root

echo "All done! Please remove the usb drive and unplug/plug your My Cloud."
echo "To access your new drive find its IP address on your router and 'ssh root@<your-ip-here>' then enter the password 'mycloud'"