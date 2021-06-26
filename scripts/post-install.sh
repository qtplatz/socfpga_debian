#!/bin/bash
#apt-get -y update && apt-get -y upgrade
apt-get -y install sudo
#apt-get -y install u-boot-tools
#apt-get -y install libncurses5-dev bc git build-essential cmake dkms
#apt-get -y install libboost-date-time-dev libboost-regex-dev libboost-filesystem-dev libboost-thread-dev libboost-program-options-dev
#apt-get -y install libboost-exception-dev libboost-serialization-dev
useradd -m -p password -G sudo -s /bin/bash nano
