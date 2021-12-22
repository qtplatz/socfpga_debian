
set( KERNELRELEASE "5.10.84" CACHE STRING "Linux kernel release such as 5.10.84" )
set( distro "bullseye" CACHE STRING "Debian codename [jessie|buster|bullseye]" )
set( target "socfpga" )
set( cross_target "armhf" )
set( target_device "de0-nano-soc" )

get_filename_component( topdir "${CMAKE_SOURCE_DIR}" DIRECTORY )

set( U_BOOT_DIR       "${topdir}/u-boot" )
set( KERNEL_SOURCE    "${topdir}/linux-${KERNELRELEASE}" )

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

find_file( SOC_SYSTEM_RBF "soc_system.rbf" "${CMAKE_CURRENT_SOURCE_DIR}/../socfpga_modules/boot" )
if ( SOC_SYSTEM_RBF )
  get_filename_component( MODULES_BOOT_DIR ${SOC_SYSTEM_RBF} DIRECTORY )
  foreach ( file "soc_system.rbf" "soc_system.dtb" "boot.scr" "boot.cmd" )
    if ( EXISTS "${MODULES_BOOT_DIR}/${file}" )
      list ( APPEND SOCFPGA_BOOT_FILES "${MODULES_BOOT_DIR}/${file}" )
    else()
      message( STATUS "${MODULES_BOOT_DIR}/${file}" "  not exists")
      unset ( SOCFPGA_BOOT_FILES )
      break()
    endif()
  endforeach()
endif()

find_file( BUILD_DIR NAMES "qtplatz.release" "socfpga_modules.release"
  PATHS  "$ENV{HOME}/src/build-armhf/" "${CMAKE_CURRENT_SOURCE_DIR}/../../build-armhf" )
if ( BUILD_DIR )
  get_filename_component( BUILD_DIR ${BUILD_DIR} DIRECTORY )
  message( STATUS "BOOT_DIR = ${BOOT_DIR}" )
  if ( BUILD_DIR )
    file( GLOB files "${BUILD_DIR}/qtplatz.release/*.deb" )
    list ( APPEND DEB_PACKAGES ${files} )
    file( GLOB files "${BUILD_DIR}/socfpga_modules.release/*.deb" )
    list ( APPEND DEB_PACKAGES ${files} )
  endif()
endif()

#----------------------------------
if ( SOCFPGA_BOOT_FILES )
  foreach( f ${SOCFPGA_BOOT_FILES} )
    message( STATUS "install-socfpga installing '${f}'" )
  endforeach()
endif()

if ( DEB_PACKAGES )
  message( STATUS "" )
  foreach( f ${DEB_PACKAGES} )
    message( STATUS "install-modules installing '${f}'" )
  endforeach()
endif()

message( STATUS "--- config.cmake loaded ---" )
