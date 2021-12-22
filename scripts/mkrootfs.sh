#!/bin/bash
# Copyright 2021-2022 (C) MS-Cheminformatics LLC
# Author: Toshinobu Hondo, Ph.D.

cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		--bootfs)
			bootfs="$2"
			shift 2
			;;
		--kernel_source)
			kernel_source="$2"
			shift 2
			;;
		--rootfs)
			rootfs_dest="$2"
			shift 2
			;;
		--rootfs_source)
			rootfs_source="$2"
			shift 2
			;;
		*)
			;;
	esac
done

if [ -z ${rootfs_dest} ]; then
	echo "rootfs destination not specified"
	exit 1
fi

if [ -z ${rootfs_source} ]; then
	echo "rootfs source not specified"
	exit 1
fi

if [ -z ${kernel_source} ]; then
	echo "kernel source not specified"
	exit 1
fi

KERNELRELEASE=$( (cd ${kernel_source}; make kernelversion) )
echo "--------------- $0 -------------------------"
echo "bootfs destination = ${bootfs}"
echo "kernel source      = ${kernel_source}"
echo "rootfs source      = ${rootfs_source}"
echo "rootfs destination = ${rootfs_dest}"
echo "KERNELRELEASE      = ${KERNELRELEASE}"
echo "--------------------------------------------"

set -x

make -C ${kernel_source} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules_install INSTALL_MOD_PATH="${rootfs_dest}"
cp "${cwd}/resizefs.sh" "${rootfs_source}/root/post-install.sh" "${rootfs_dest}/root/"

# Kernel source copy to destination
tar Ccf "$(dirname ${kernel_source})" - "$(basename ${kernel_source})" | tar Cxf "${rootfs_dest}/usr/src/" -

# re-link
/sbin/chroot "${rootfs_dest}" /bin/bash <<EOF
echo ============== chroot ================ `pwd`
echo ============== chroot ================ ${rootfs_dest}
echo ============== chroot ================ ${KERNELRELEASE}
set -x
( cd /lib/modules/${KERNELRELEASE}; \
  ln -sf /usr/src/linux-${KERNELRELEASE} source; \
  ln -sf /usr/src/linux-${KERNELRELEASE} build )
chmod +x /root/resizefs.sh
chmod +x /root/post-install.sh
make -C /usr/src/linux-${KERNELRELEASE} scripts
make -C /usr/src/linux-${KERNELRELEASE} prepare0
( cd /lib/modules; ln -s ${KERNELRELEASE} $(uname -r) ) # fake unmae
EOF

exit 0
