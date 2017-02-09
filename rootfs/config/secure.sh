#!/bin/bash

apt-get update
apt-get upgrade
apt-get install fail2ban
passwd -d root
passwd cloud
echo "It is strongly recommended that you disable password ssh access and use a public/private key pair."