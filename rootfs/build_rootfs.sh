#!/bin/bash


## check sudo/root
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root"; exit 1; fi


## setup
OUTPUT_DIR="../build/rootfs"


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
    --include=nano,sudo,openssh-server \
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

# add symlink to debian init
ln -s /sbin/init $OUTPUT_DIR/linuxrc

# add hostnames
cp config/hosts $OUTPUT_DIR/etc/hosts

# add hostname
cp config/hostname $OUTPUT_DIR/etc/hostname

# add sources
cp config/sources.list $OUTPUT_DIR/etc/apt/sources.list

# setup ethernet devices
cp config/interfaces $OUTPUT_DIR/etc/network/interfaces

# add fstab
cp ../shared/fstab $OUTPUT_DIR/etc/fstab

# add folder for mounting data drive
mkdir -p $OUTPUT_DIR/data
chown 1000:1000 $OUTPUT_DIR/data

# add led control script
cp ../shared/led $OUTPUT_DIR/usr/sbin/led

# fix sudo bin permissions (not sure why it doesn't install correctly)
sudo chroot ../build/rootfs bash -c 'chmod 4755 /usr/bin/sudo'

# setup ssh server
chroot $OUTPUT_DIR bash -c 'sed -i "s/^PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config'
chroot $OUTPUT_DIR bash -c 'sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config'

# create default admin user
#sudo chroot ../build/rootfs bash -c 'echo "root:mycloud" | chpasswd'
sudo chroot ../build/rootfs bash -c 'adduser --gecos "" --disabled-password cloud'
sudo chroot ../build/rootfs bash -c 'echo "cloud:mycloud" | chpasswd'
sudo chroot ../build/rootfs bash -c 'sudo adduser cloud sudo'
# set user's path

# add script to secure 
cp config/secure.sh $OUTPUT_DIR/usr/bin/secure.sh

# zip up the root fs
(cd $OUTPUT_DIR && tar -czvf ../rootfs.tar.gz *)

echo "done!"

# # install fail2ban
# chroot $OUTPUT_DIR bash -c 'apt-get install fail2ban -y'

#Deactivate using passwords for authentication (PasswordAuthentication no).
#Deactivate using the root account (PermitRootLogin no).