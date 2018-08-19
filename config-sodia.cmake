set( target_device "sodia" )

set( DESIGN_ROOT       "$ENV{HOME}/src/altera/sodia-fpga/sodia" CACHE STRING "sodia board quartus project dir")

set( SOCFPGA_GHRD     "${DESIGN_ROOT}/sodia/ghrd" )

set( RBF "${DESIGN_ROOT}/dts/sodia.rbf" )
set( DTS "${DESIGN_ROOT}/dts/sodia.dts" )
set( DTB "${DESIGN_ROOT}/dts/sodia.dtb" )

find_file( MBR "mbr.img.bz2" "${DESIGN_ROOT}/mkimage" )
if ( NOT MBR )
  message( FATAL_ERROR "mbr.img.bz2 not found in ${DESIGN_ROOT}/mkimage/" )
endif()

find_file( BOOTCMD u-boot.scr "${DESIGN_ROOT}/dts" )
if ( BOOTCMD )
  list ( APPEND BOOT_FILES ${BOOTCMD} )
else()
  message( FATAL_ERROR "u-boot.scr not found in ${DESIGN_ROOT}/dts/" )
endif()

message( STATUS "## config-sodia.cmake ##" )

