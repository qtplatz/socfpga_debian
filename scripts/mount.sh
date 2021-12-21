#/bin/sh
# Copyright 2017-2022 (C) MS-Cheminformatics LLC
# Project supported by Osaka University Graduate School of Science
# Author: Toshinobu Hondo, Ph.D.

cwd="$(cd $(dirname "$0") && pwd)"

if [ -z ${bootfs} ]; then
	bootfs="/mnt/bootfs"
fi
if [ -z ${rootfs} ]; then
	rootfs="/mnt/rootfs"
fi

${cwd}/umount-all.sh --detach ${bootfs} ${rootfs}

if [ $# -lt 1 ]; then
    echo "image file not specified"
    exit
fi

set +x

loop0=$(sudo losetup --show -f -P $1) || exit 1
echo sudo mount ${loop0}p1 ${bootfs}
sudo mount ${loop0}p1 ${bootfs} || exit 1
echo sudo mount ${loop0}p2 ${rootfs}
sudo mount ${loop0}p2 ${rootfs} || exit 1
