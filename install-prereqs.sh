#!/bin/bash

# SECURITY ERRORS
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5

sudo apt-get update
# sudo apt-get -y upgrade

sudo apt-get -y install bridge-utils debootstrap ifenslave ifenslave-2.6 lsof lvm2 tcpdump vlan aptitude build-essential git ntp ntpdate python-dev
