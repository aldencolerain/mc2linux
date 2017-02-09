#!/bin/bash

# assumes your running ubuntu 14.04 or 16.04

apt-get install gcc-arm-linux-gnueabihf
apt-get install build-essential libncurses5 libncurses5-dev u-boot-tools
apt-get install u-boot-tools
apt-get install debootstrap
apt-get install qemu-user-static
apt-get install debian-archive-keyring