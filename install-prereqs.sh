#!/bin/bash

apt-get update
apt-get -y upgrade

apt-get -y install bridge-utils debootstrap ifenslave ifenslave-2.6 lsof lvm2 tcpdump vlan aptitude build-essential git ntp ntpdate python-dev
