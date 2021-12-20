
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
  COMMAND bootfs=${MNT_BOOTFS} rootfs=${MNT_ROOTFS} ${TOOLS}/mkfs.sh ${IMGFILE} ${U_BOOT_SPL} # <-- SPL
  COMMAND ${SUDO} ${CP} ${BOOT_FILES} ${MNT_BOOTFS}
  COMMAND ${SUDO} ${CP} -ax "${ROOTFS}/*" "${MNT_ROOTFS}"
  COMMAND echo "======== modules_install ======"
  COMMAND ${SUDO} ${MAKE} -C ${KERNEL_SOURCE} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4 modules_install INSTALL_MOD_PATH=${MNT_ROOTFS}
  COMMAND echo "======== end modules_install ======"
  COMMAND ${SUDO} ${CP} ${TOOLS}/resizefs.sh ${ROOTFS}/root/post-install.sh ${MNT_ROOTFS}/root/
  COMMAND ${SUDO} chmod +x ${MNT_ROOTFS}/root/resizefs.sh ${MNT_ROOTFS}/root/post-install.sh
  COMMAND ${SUDO} ${TOOLS}/umount-all.sh ${MNT_BOOTFS} ${MNT_ROOTFS}
  COMMAND ${SUDO} ${TOOLS}/detach-all.sh
  #COMMAND echo "-- image mount on ${MNT_BOOTFS}, ${MNT_ROOTFS} -- You have to install applications manually, then run make umount --"
  DEPENDS ${ROOTFS} ${U_BOOT_SPL} ${BOOT_FILES} ${PACKAGES}
  USES_TERMINAL
  COMMENT "-- making ${IMGFILE} system --"
  )

add_custom_target( umount
  COMMAND ${SUDO} ${TOOLS}/umount-all.sh ${MNT_BOOTFS} ${MNT_ROOTFS}
  COMMAND ${SUDO} ${TOOLS}/detach-all.sh
  COMMENT "-- umounting ${MNT_BOOTFS} ${MNT_ROOTFS} --"
  )
