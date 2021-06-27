de0-nano-soc debian10 SD Card image generator -- with device-tree overlay enabled.
=====

This project contains cmake and dependent bash scripts for de0-nano-soc debian boot SD-Card.

Prerequisite
===============

1. Linux (debian9) host (x86_64).
2. Multiarch for armhf enabled on host.
3. QEMU arm

Dependent debian packages
===========================

```
sudo dpkg --add-architecture armhf
sudo apt-get -y install crossbuild-essential-armhf
sudo apt-get -y install bc build-essential cmake dkms git libncurses5-dev
(May be some else...)
```

Prepare U-Boot
===========================
1. Get u-boot source from source.denx.de git repo into the sibling (adjacent) directory to socfpga_debian.

```bash
SOCFPGA=~/src/de0-nano-soc
mkdir -p $SOCFPGA
cd $SOCFPGA
git clone https://github.com/qtplatz/socfpga_debian
git clone https://source.denx.de/u-boot/u-boot.git
```
2. Configure u-boot, apply patch and build (A patch is just add -@ option for dt-overlay ready dtb file)

```bash
cd $SOCFPGA/u-boot/
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- distclean
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- socfpga_de0_nano_soc_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig
patch -p1 < ../socfpga_debian/u-boot.patch
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4
```
You should have the following u-boot files by now, which are required to make an SDCard image.
    1. `u-boot/u-boot.dtb`
    1. `u-boot/u-boot-with-spl.sfp`
    1. `u-boot/u-boot.img`

Build Kernel
=============================

```bash
cd linux-<version>
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- socfpga_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4
```

Build img
=============================

1. Create build directory, and run CMake against socfpga_debian (this) directory

```bash
mkdir $SOCFPGA/build
cd $SOCFPGA/build
cmake $SOCFPGA/socfpga_debian
```
Makefile will be created with successful CMake command.  You can find a list of make sub commands by typing `make help`.
1. run 'make' will create Debian root file system.  This process requires root privilege due to elevated command is in script files. After 'rootfs' was created, then
1. run 'make img' to make SD Card image file.  This step also requires root privilege for 'sudo' command.

Edit `config.cmake` under a top directory of socfpga_debian for different kernel versions or u-boot locations.

Boot `de0-nano-soc` with newly prepared SDCard
=============================

1. Using dd command, copy generated img file to SDCard.
```bash
dd if=socfpga_buster-5.10.36-dev.img of=/dev/sdX bs=1M; sync; sync; sync
```
1. Set SDCard to `de0-nano-soc`
1. Connect USB cable to `de0-nano-soc`
1. And, connect terminal using `screen /dev/ttyUSB0 115200`, and then power on.
1. You can login as root without password
1. Initial SDCard allocates only 2.5GB image, it can be expanded to full SDCard size by executing `/root/resizefs.sh` script, and reboot.
