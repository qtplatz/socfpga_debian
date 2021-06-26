#!/bin/bash
# Recompile with:
# mkimage -C none -A arm -T script -d boot.cmd boot.scr

setenv fsck.repair yes
setenv fbcon map:0
setenv bootargs console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait fsck.repair=${fsck.repair} panic=10 ${extra} fbcon=${fbcon}

fatload mmc 0 ${kernel_addr_r} zImage
fatload mmc 0 ${fdt_addr_r} u-boot.dtb
fdt addr ${fdt_addr_r}

bootz ${kernel_addr_r} - ${fdt_addr_r}
