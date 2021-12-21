#!/bin/bash
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

if [ -z ${rootfs} ]; then
	echo "rootfs environment variable not defined"
	exit 1
fi

if [ -z ${bootfs} ]; then
	echo "bootfs environment variable not defined"
	exit 1
fi

if [ ! -f ${rootfs} ]; then
	sudo mkdir -p ${rootfs}
fi

if [ ! -f ${bootfs} ]; then
	sudo mkdir -p ${bootfs}
fi

${cwd}/detach-all.sh

mkimage() {
	# 2.0GB
	#	dd if=/dev/zero of=$1 bs=1M count=2048
	# 4GiB
	dd if=/dev/zero of=$1 bs=1M count=4096
}

# new primary partition=3, start=2048, size=+1M
# new primary partition=1, start=4096, size=+128M
# new primary partition=2, start=266240, size=(to end of img)
# type partion=1, 'b' (W95 FAT32)
# type partion=3, 'a2'

partition() {
    echo "Partitioning $1"
    sudo fdisk $1 <<EOF>/dev/null
n
p
3
2048
+1M
n
p
1
4096
+128M
n
p
2
266240

t
1
b
t
3
a2
w
EOF
}

mkimage $1 || exit 1
partition $1 || exit 1

# partition table should be:
#----------------------------------------------------------------
#  sudo fdisk /dev/loop0
#  Device       Boot  Start     End Sectors  Size Id Type
#  /dev/loop0p1        4096  266239  262144  128M  b W95 FAT32
#  /dev/loop0p2      266240 4194303 3928064  2.4G 83 Linux
#  /dev/loop0p3        2048    4095    2048    1M a2 unknown
#----------------------------------------------------------------

#makefs $1 $2
loop0=$(sudo losetup --show -f -P $1) || exit 1
echo $loop0

# copy preloader (u-boot-with-spl.sfp) to loop0p3  (type a2 partition)
sudo dd if=$2 of=${loop0}p3 bs=1024

# format loop0p1 as Win95 DOS partition
sudo mkfs.vfat ${loop0}p1 || exit 1
sudo e2label ${loop0}p1 bootfs

# format loop0p2 as ext4 linux partition (linux rootfs)
sudo mkfs.ext4 ${loop0}p2 || exit 1
sudo e2label ${loop0}p2 rootfs

sudo mount ${loop0}p1 $bootfs || exit 1
sudo mount ${loop0}p2 $rootfs || exit 1
