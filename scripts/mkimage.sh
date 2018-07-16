#!/bin/bash
# Copyright 2017-2018 (C) MS-Cheminformatics LLC
# Project supported by Osaka University Graduate School of Science
# Author: Toshinobu Hondo, Ph.D.
#
# See: http://linux-sunxi.org/Bootable_SD_card
#-------------------- (1KB block) -------------------
#    0      8KB Unused, available for MBR
#    8     32KB Initial SPL Loader
#   40    504KB U-Boot
#  544    128KB environment
#  672    128KB Falcon mode boot params
#  800    -     Falcon mode kernel start
# 1024   -     Free for partion
#----------------------------------------------------

set -x
cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -ne 2 ]; then
	echo "Usage: $0 image-file u-boot.bin"
	exit 1
fi

if [ ! -f $2 ]; then
	exho "$2 not found"
	exit 1
fi

if [ -z $rootfs ]; then
	rootfs="/mnt/rootfs"
fi

if [ -z $bootfs ]; then
	bootfs="/mnt/bootfs"
fi

if [ ! -f $rootfs ]; then
	sudo mkdir -p $rootfs
fi

if [ ! -f $bootfs ]; then
	sudo mkdir -p $bootfs
fi

${cwd}/detach-all.sh

mkimage() {
	dd if=/dev/zero of=$1 bs=1M count=2048
}

partition() {
    echo "Partitioning $1"
    sudo fdisk $1 <<EOF>/dev/null
n
p
1
49152
+40M
n
p
2
131072

w
EOF
}

mkimage $1 || exit 1
partition $1 || exit 1

loop0=$(sudo losetup --show -f -P $1) || exit 1
echo $loop0

# Bootloader write to offset 8192
dd if=$2 of=$loop0 bs=1024 seek=8

sudo mkfs.vfat ${loop0}p1 || exit 1
sudo e2label ${loop0}p1 bootfs

sudo mkfs.ext4 ${loop0}p2 || exit 1
sudo e2label ${loop0}p2 rootfs

sudo mount ${loop0}p1 $bootfs || exit 1
sudo mount ${loop0}p2 $rootfs || exit 1

exit 0
