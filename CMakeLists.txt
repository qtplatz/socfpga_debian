#
cmake_minimum_required ( VERSION 3.7 )  # for GREATER_EQUAL
cmake_policy( SET CMP0020 NEW )
cmake_policy( SET CMP0042 NEW )
cmake_policy( SET CMP0053 NEW )

project (socfpga_debian)

list( APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules" )

include(config.cmake)
set ( TOOLS ${CMAKE_SOURCE_DIR}/scripts )

#------------------------ debian rootfs ----------------
set ( ROOTFS ${CMAKE_BINARY_DIR}/arm-linux-gnueabihf-rootfs-${distro} )

add_custom_command(
  OUTPUT ${ROOTFS}
  COMMAND distro=${distro} targetdir=${ROOTFS} ${CMAKE_SOURCE_DIR}/scripts/debootstrap.sh
  )

add_custom_target( rootfs ALL DEPENDS ${ROOTFS} ${CMAKE_SOURCE_DIR}/CMakeLists.txt )
#------------------------ end debian rootfs ----------------

#----------------------- .img file --------------------
set ( MNT_BOOTFS "/mnt/bootfs" )
set ( MNT_ROOTFS "/mnt/rootfs" )
set ( IMGFILE ${CMAKE_BINARY_DIR}/${target}_${distro}-${KERNELRELEASE}-dev.img )
#<----------------------- .img file --------------------

#------------- SDCard image ---------------
find_file( U_BOOT_SPL "u-boot-with-spl.sfp" HINTS "${U_BOOT_BUILD_DIR}" )
find_file( KERNELIMAGE "zImage" HINTS "${KERNEL_BUILD_DIR}/linux-${KERNELRELEASE}/arch/arm/boot" )

if ( EXISTS ${RBF} )
  list ( APPEND BOOT_FILES ${RBF} )
endif()

if ( EXISTS ${DTS} )
  list ( APPEND BOOT_FILES ${DTS} )
endif()

if ( EXISTS ${DTB} )
  list ( APPEND BOOT_FILES ${DTB} )
endif()

if ( EXISTS "${KERNEL_BUILD_DIR}/linux-${KERNELRELEASE}/arch/arm/boot/zImage" )
  list ( APPEND BOOT_FILES "${KERNEL_BUILD_DIR}/linux-${KERNELRELEASE}/arch/arm/boot/zImage" )
endif()

if ( EXISTS "${KERNEL_BUILD_DIR}/linux-${KERNELRELEASE}/.config" )
  list ( APPEND BOOT_FILES "${KERNEL_BUILD_DIR}/linux-${KERNELRELEASE}/.config" )
endif()

include ( mkimage )
add_custom_target( img DEPENDS ${IMGFILE} ${BOOT_FILES} ${PACKAGES} VERBATIM )

#------------- end SDCard image ---------------

message( STATUS "--------------------------------------------" )
message( STATUS "KERNELRELEASE   = " ${KERNELRELEASE} )
message( STATUS "KERNEL_SOURCE   = " ${KERNEL_SOURCE} )
message( STATUS "distro          = " ${distro} )
message( STATUS "cross_target    = " ${cross_target} )
message( STATUS "target_device   = " ${target_device} )
message( STATUS "ROOTFS          = " ${ROOTFS} )
message( STATUS )
message( STATUS "IMGFILE         = " ${IMGFILE} )
message( STATUS "U_BOOT_SPL\t" ${U_BOOT_SPL} )
message( STATUS "BOOT_FILES        " )
foreach( i ${BOOT_FILES} )
  message( STATUS "\t\t${i}" )
endforeach()
message( STATUS "--------------------------------------------" )
