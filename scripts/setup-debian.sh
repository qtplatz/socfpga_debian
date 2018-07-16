#!/bin/bash
# Copyright 2017-2018 (C) MS-Cheminformatics LLC
# Project supported by Osaka University Graduate School of Science
# Author: Toshinobu Hondo, Ph.D.

mnt=/mnt
if (( $# >= 0 )); then
    mnt=$1
fi

outfile=${mnt}/post-install.sh

cat <<EOF>${outfile}
#!/bin/bash
apt-get -y update && apt-get -y upgrade
apt-get -y install sudo

make -C /usr/src/linux-${KERNELRELEASE} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules_prepare
ln -sf /usr/src/linux-${KERNELRELEASE} /lib/modules/${KERNELRELEASE}/build
ln -sf /usr/src/linux-${KERNELRELEASE} /lib/modules/${KERNELRELEASE}/source
rm -f \$0
EOF
chmod 0700 $outfile

cat <<EOF>${mnt}/configure_modules.sh
#!/bin/bash
make -C /usr/src/linux-${KERNELRELEASE} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules_prepare
ln -sf /usr/src/linux-${KERNELRELEASE} /lib/modules/${KERNELRELEASE}/build
ln -sf /usr/src/linux-${KERNELRELEASE} /lib/modules/${KERNELRELEASE}/source
EOF
chmod 0700 ${mnt}/configure_modules.sh


