
if ( MNT_BOOTFS STREQUAL "" )
  message( FATAL_ERROR "bootfs mount point 'MNT_BOOTFS' not defined" )
endif()

if ( MNT_ROOTFS STREQUAL "" )
  message( FATAL_ERROR "rootfs mount point 'MNT_ROOTFS' not defined" )
endif()

if ( KERNEL_SOURCE STREQUAL "" )
  message( FATAL_ERROR "Emtpy KERNEL_SOURCE" )
endif()

set ( CP cp )
set ( SUDO sudo )
set ( TAR tar )
set ( MAKE make )

# --- generate raw image filesystem on file, loop mount on mnt_bootfs, ext3 ---

add_custom_command(
  OUTPUT ${IMGFILE}
  COMMAND ${SUDO} ${TOOLS}/umount-all.sh ${MNT_BOOTFS} ${MNT_ROOTFS}
  COMMAND ${SUDO} ${TOOLS}/detach-all.sh
  COMMAND bootfs=${MNT_BOOTFS} rootfs=${MNT_ROOTFS} ${TOOLS}/mkfs.sh ${IMGFILE} ${U_BOOT_SPL}
  COMMAND echo "-- making boot in ${MNT_BOOTFS} ---"
  COMMAND ${SUDO} ${CP} ${BOOT_FILES} ${MNT_BOOTFS}
  COMMAND echo "-- making root in ${MNT_ROOTFS} ---"
  COMMAND ${SUDO} ${CP} -ax "${ROOTFS}/*" "${MNT_ROOTFS}"
  COMMAND echo "======== modules_install ======"
  COMMAND echo ${SUDO} ${MAKE} -C ${KERNEL_SOURCE} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4 modules_install INSTALL_MOD_PATH=${MNT_ROOTFS}
  COMMAND ${SUDO} ${MAKE} -C ${KERNEL_SOURCE} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4 modules_install INSTALL_MOD_PATH=${MNT_ROOTFS}
  COMMAND echo "======== end modules_install ======"
  #COMMAND ${SUDO} rootfs=${MNT_ROOTFS} ${TOOLS}/network-interface.sh --static --ip=192.168.1.132 --gw=192.168.1.1 --netmask=255.255.255.0
  COMMAND ${SUDO} rootfs=${MNT_ROOTFS} ${TOOLS}/network-interface.sh --dhcp
  COMMAND echo "-- resizefs.sh ---"  
  COMMAND ${SUDO} ${CP} ${TOOLS}/resizefs.sh ${MNT_ROOTFS}/root
  COMMAND ${SUDO} chmod +x ${MNT_ROOTFS}/root/resizefs.sh
  COMMAND echo "-- copy kernel source and config ---"  
  COMMAND ${SUDO} tar xf ~/Downloads/linux-${KERNELRELEASE}.tar.xz -C ${MNT_ROOTFS}/usr/src
  COMMAND ${SUDO} ${CP} ${KERNEL_SOURCE}/.config ${MNT_ROOTFS}/usr/src/linux-${KERNELRELEASE}
  COMMAND echo "-- generating post-install script on ${MNT_ROOTFS} ---"  
  COMMAND ${SUDO} KERNELRELEASE='${KERNELRELEASE}' BOOST_VERSION='${BOOST_VERSION}' ${TOOLS}/create-dev-script.sh "${MNT_ROOTFS}"
  COMMAND echo "========================================================="
  COMMAND echo "-- executing ${MNT_ROOTFS}/post-install, copy kernel source ---"  
  COMMAND ${SUDO} chroot ${MNT_ROOTFS} /bin/bash -c ./post-install.sh
  COMMAND echo "========================================================="
  COMMAND echo "-- image mount on ${MNT_BOOTFS}, ${MNT_ROOTFS} -- You have to install applications manually, then run make umount --"
  DEPENDS ${ROOTFS} ${U_BOOT_SPL} ${BOOT_FILES} ${PACKAGES}
  USES_TERMINAL
  COMMENT "-- making ${IMGFILE} system --"
  )

#add_custom_target( img  DEPENDS ${IMGFILE}  VERBATIM )

add_custom_target( umount
  COMMAND ${SUDO} ${TOOLS}/umount-all.sh ${MNT_BOOTFS} ${MNT_ROOTFS}
  COMMAND ${SUDO} ${TOOLS}/detach-all.sh
  COMMENT "-- umounting ${MNT_BOOTFS} ${MNT_ROOTFS} --"
  )