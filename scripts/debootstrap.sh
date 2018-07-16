#!/bin/bash
# Copyright 2017-2018 (C) MS-Cheminformatics LLC
# Project supported by Osaka University Graduate School of Science
# Author: Toshinobu Hondo, Ph.D.

stage=

for i in "$@"; do
    case "$i" in
	--second-stage)
	    stage="second"
	    ;;
	*)
	    echo "unknown option $i"
	    ;;
    esac
done

if [ -z $stage ]; then

    if [ -z $targetdir ]; then
		targetdir=arm-linux-gnueabihf-rootfs-$distro
    fi
    
    if [ -z $distro ]; then
		distro=jessie
    fi

    sudo apt-get install qemu-user-static debootstrap binfmt-support
    
    mkdir $targetdir
    sudo debootstrap --arch=armhf --foreign $distro $targetdir
    
    sudo cp /usr/bin/qemu-arm-static $targetdir/usr/bin/
    sudo cp /etc/resolv.conf $targetdir/etc
    sudo cp $0 $targetdir/
    
    echo "************ run following commands ***************"
    echo "sudo chroot $targetdir"
    echo "distro=$distro /$(basename $0) --second-stage"
    echo "***************************************************"

else

    if [ -z $distro ]; then
		distro=jessie
    fi
    
    export LANG=C
    
    /debootstrap/debootstrap --second-stage
    
    cat <<EOF>/etc/apt/sources.list
deb http://ftp.jaist.ac.jp/debian $distro main contrib non-free
deb-src http://ftp.jaist.ac.jp/debian $distro main contrib non-free
deb http://ftp.jaist.ac.jp/debian $distro-updates main contrib non-free
deb-src http://ftp.jaist.ac.jp/debian $distro-updates main contrib non-free
deb http://security.debian.org/debian-security $distro/updates main contrib non-free
deb-src http://security.debian.org/debian-security $distro/updates main contrib non-free
EOF
    
    cat <<EOF >/etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet dhcp
# This is an autoconfigured IPv6 interface
iface eth0 inet6 auto
EOF

    apt-get update
    apt-get -y install locales dialog
    dpkg-reconfigure locales
    
    apt-get -y install openssh-server ntpdate i2c-tools
    
    passwd -d root

    host=nano
    echo $host > /etc/hostname
    echo "127.0.1.1	$host" >> /etc/hosts
    
    rm -f $0
    
fi

