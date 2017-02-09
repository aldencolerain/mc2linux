#!/bin/bash


## check sudo/root
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root"; exit 1; fi


## setup
OUTPUT_DIR="../build/initrd"


## cleanup
echo "cleaning up old build..."
rm -r $OUTPUT_DIR


## build
echo "building..."

# create basic debian rootfs
debootstrap \
	--arch=armhf \
	--keyring=/usr/share/keyrings/debian-archive-keyring.gpg \
	--verbose \
	--foreign \
	--variant=minbase \
	--include=nano \
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

# add led control script
cp ../shared/led $OUTPUT_DIR/usr/sbin/led

# add init script
cp config/init $OUTPUT_DIR/init

# add mnt folder for root fs
mkdir $OUTPUT_DIR/mnt/root


## build image
bash ../shared/build_image.sh $OUTPUT_DIR ./uRamdiskStandard