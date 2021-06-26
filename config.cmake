
set( KERNELRELEASE "5.10.36" )
set( distro "buster" )
set( target "socfpga" )
set( cross_target "armhf" )
set( target_device "de0-nano-soc" )

get_filename_component( topdir "${CMAKE_SOURCE_DIR}" DIRECTORY )

set( U_BOOT_DIR       "${topdir}/u-boot" )
set( KERNEL_SOURCE    "${topdir}/linux-5.10.36" )

set ( DTB             "${U_BOOT_DIR}/u-boot.dtb" )
set ( DTS             "${U_BOOT_DIR}/arch/arm/boot/dts/socfpga_cyclone5_de0_nano_soc.dts" )
set ( U_BOOT_SPL      "${U_BOOT_DIR}/u-boot-with-spl.sfp" )
set ( U_BOOT_IMG      "${U_BOOT_DIR}/u-boot.img" )

set ( BOOT_SCR        "${CMAKE_SOURCE_DIR}/src/boot.scr" )
set ( BOOT_CMD        "${CMAKE_SOURCE_DIR}/src/boot.cmd" )

set ( BOOT_FILES
  ${U_BOOT_IMG}
  ${DTB}
  ${BOOT_SCR}
  ${BOOT_CMD}
  )

message( "## config.cmake ##" )
