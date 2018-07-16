#!/bin/bash

mnt=/mnt
if (( $# >= 0 )); then
    mnt=$1
fi

outfile=${mnt}/post-install.sh

cat <<EOF>${outfile}
#!/bin/bash
apt-get -y update && apt-get -y upgrade
apt-get -y install sudo
apt-get -y install u-boot-tools
apt-get -y install libncurses5-dev bc git build-essential cmake dkms
apt-get -y install libboost-date-time-dev libboost-regex-dev libboost-filesystem-dev libboost-thread-dev libboost-program-options-dev 
apt-get -y install libboost-exception-dev libboost-serialization-dev
apt-get -y install libsocketcan-dev libsocketcan2 can-utils vim
useradd -m -p paQe5lBRZr7FQ -G sudo -s /bin/bash weight

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


