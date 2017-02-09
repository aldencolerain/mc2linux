#!/bin/bash


## check sudo/root
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root"; exit 1; fi


## setup
OUTPUT_DIR="../build/recovery"


## cleanup
echo "cleaning up old build..."
rm -r $OUTPUT_DIR


## build
echo "building..."

# create basic debian $OUTPUT_DIR
debootstrap \
	--arch=armhf \
	--keyring=/usr/share/keyrings/debian-archive-keyring.gpg \
	--verbose \
	--foreign \
	--variant=minbase \
	--include=nano,parted \
	jessie \
	$OUTPUT_DIR

# add qemu static to basic debian system so we can run the arm binaries using qemu syscall emulation for phase 2
cp /usr/bin/qemu-arm-static $OUTPUT_DIR/usr/bin

# build stage two
echo "finishing build using static arm emulator..."

# run second stage of debosotrap build inside arm emulator
chroot $OUTPUT_DIR /debootstrap/debootstrap --second-stage


## configure
echo "configuring..."

# add busybox (https://busybox.net/downloads/binaries/1.21.1/busybox-armv7l)
sudo cp config/busybox $OUTPUT_DIR/bin/busybox
sudo ln -s busybox $OUTPUT_DIR/bin/ash
sudo ln -s busybox $OUTPUT_DIR/bin/cttyhack
sudo ln -s busybox $OUTPUT_DIR/bin/telnetd
sudo ln -s busybox $OUTPUT_DIR/bin/ip
sudo ln -s busybox $OUTPUT_DIR/bin/ifup
sudo ln -s busybox $OUTPUT_DIR/bin/ifconfig
sudo ln -s busybox $OUTPUT_DIR/bin/udhcpc

# add hostnames
sudo cp config/hosts $OUTPUT_DIR/etc/hosts

# add hostname
sudo cp config/hostname $OUTPUT_DIR/etc/hostname

# setup ethernet devices
sudo cp config/interfaces $OUTPUT_DIR/etc/network/interfaces
sudo mkdir -p $OUTPUT_DIR/etc/network/if-pre-up.d
sudo mkdir -p $OUTPUT_DIR/etc/network/if-up.d
sudo mkdir -p $OUTPUT_DIR/etc/network/if-down.d
sudo mkdir -p $OUTPUT_DIR/etc/network/if-post-down.d
sudo cp config/udhcp $OUTPUT_DIR/etc/network/if-pre-up.d
sudo cp config/dhcp.script $OUTPUT_DIR/etc/

# add led control script
sudo cp ../shared/led $OUTPUT_DIR/usr/sbin/led

# add init script
sudo cp config/init $OUTPUT_DIR/init

# add install script
sudo cp config/install_debian.sh $OUTPUT_DIR/bin/install_debian

# add mnt folder for root
sudo mkdir $OUTPUT_DIR/mnt/root
sudo mkdir -p /dev/pts


## build image
bash ../shared/build_image.sh $OUTPUT_DIR ./uRamdiskRecovery