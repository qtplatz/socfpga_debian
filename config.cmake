
set( KERNELRELEASE "4.4.94" )
set( distro "stretch" )
set( target "socfpga" )
set( cross_target "armhf" )
set( target_device "de0-nano-soc" )

get_filename_component( topdir "${CMAKE_SOURCE_DIR}" DIRECTORY )

set( U_BOOT_BUILD_DIR "${topdir}/socfpga_u-boot/build/u-boot-de0-nano-soc" )
set( KERNEL_BUILD_DIR "${topdir}/socfpga_kernel/build" )
set( KERNEL_SOURCE    "${KERNEL_BUILD_DIR}/linux-${KERNELRELEASE}" )

set( SOCFPGA_GHRD     "${topdir}/socfpga/de0_nano_soc_ghrd" )
set( RBF "${topdir}/socfpga/dts/soc_system.rbf" )
set( DTS "${topdir}/socfpga/dts/soc_system.dts" )
set( DTB "${topdir}/socfpga/dts/soc_system.dtb" )

message( "#####################################" )
