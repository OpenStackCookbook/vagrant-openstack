#!/bin/bash

# SECURITY ERRORS
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5

mkdir -p /etc/apt/apt.conf.d
echo "Acquire::http { Proxy \"http://192.168.1.1:3128\"; };" > /etc/apt/apt.conf.d/01squid

export DEBIAN_FRONTEND=noninteractive
echo "set grub-pc/install_devices /dev/sda" | debconf-communicate

sudo rm -vf /var/lib/apt/lists/*
sudo apt-key update
sudo apt-get update
sudo apt-get -y upgrade

sudo apt-get -y install bridge-utils debootstrap ifenslave ifenslave-2.6 lsof lvm2 tcpdump vlan aptitude build-essential git ntp ntpdate python-dev libyaml-dev libpython2.7-dev libffi-dev libssl-dev
