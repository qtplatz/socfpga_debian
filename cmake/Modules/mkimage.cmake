
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
  COMMAND ${SUDO} ${TOOLS}/umount-all.sh --detach ${MNT_BOOTFS} ${MNT_ROOTFS}
  COMMAND bootfs=${MNT_BOOTFS} rootfs=${MNT_ROOTFS} ${TOOLS}/mkfs.sh ${IMGFILE} ${U_BOOT_SPL} # <-- SPL
  COMMAND ${SUDO} ${CP} ${BOOT_FILES} ${MNT_BOOTFS}
  COMMAND ${SUDO} ${CP} -ax "${ROOTFS}/*" "${MNT_ROOTFS}"
  COMMAND ${SUDO} ${TOOLS}/mkrootfs.sh --bootfs ${MNT_BOOTFS} --rootfs ${MNT_ROOTFS} --rootfs_source ${ROOTFS} --kernel_source ${KERNEL_SOURCE}
  COMMAND ${SUDO} ${TOOLS}/umount-all.sh --detach ${MNT_BOOTFS} ${MNT_ROOTFS}
  DEPENDS ${ROOTFS} ${U_BOOT_SPL} ${BOOT_FILES} ${PACKAGES}
  USES_TERMINAL
  COMMENT "-- making ${IMGFILE} system --"
  )

add_custom_target( umount
  COMMAND ${SUDO} ${TOOLS}/umount-all.sh --detach ${MNT_BOOTFS} ${MNT_ROOTFS}
  COMMENT "-- umounting ${MNT_BOOTFS} ${MNT_ROOTFS} --"
  )

add_custom_target( mount
  COMMAND bootfs=${MNT_BOOTFS} rootfs=${MNT_ROOTFS} ${TOOLS}/mount.sh ${IMGFILE}
  COMMENT "-- ounting ${MNT_BOOTFS} ${MNT_ROOTFS} --"
  )
