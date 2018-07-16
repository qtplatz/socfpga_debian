#!/bin/bash
# Copyright 2017-2018 (C) MS-Cheminformatics LLC
# Project supported by Osaka University Graduate School of Science
# Author: Toshinobu Hondo, Ph.D.

mnt=/mnt
config=dhcp
ip=192.168.1.132

for i in "$@"; do
    case "$i" in
	--static)
	    config=static
	    ;;
	--dhcp)
	    config=dhcp
	    ;;
	*)
	    ip="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$i")"
	    echo IP=$ip
	    ;;
    esac
done

if [ ! -d ${mnt}/etc/network ]; then
    mkdir -p ${mnt}/etc/network
fi

if [ $config=dhcp ]; then

    cat <<EOF>${mnt}/etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet dhcp
EOF

elif [ $config=static ] && [ ! -z $ip ] ; then
    cat <<EOF>${mnt}/etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
	address	$ip 
	netmask	255.255.255.0
	gateway	192.168.0.1
EOF
fi

    
