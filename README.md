de0-nano-soc debian10 SD Card image generator -- with device-tree overlay enabled.
=====

This project contains cmake and dependent bash scripts for de0-nano-soc debian boot SD-Card.

Prerequisite
===============

1. Linux (debian10) host (x86_64).
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
2. Configure u-boot, apply a patch and build (A patch adds -@ option for dt-overlay ready dtb file, so that is not necessary if you do not use dt-overlay.

```bash
cd $SOCFPGA/u-boot/
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- distclean
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- socfpga_de0_nano_soc_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig
patch -p1 < ../socfpga_debian/u-boot.patch
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4
```
You should have the following u-boot files by now, which are required to make an SDCard image.
The .dtb file generated here is enough to boot the soc; it will be overridden with the FPGA configuration later.

1. `u-boot/u-boot.dtb`
1. `u-boot/u-boot-with-spl.sfp`
1. `u-boot/u-boot.img`

Build Kernel
=============================

```bash
git clone https://github.com/altera-opensource/linux-socfpga
cd linux-socfpga
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- socfpga_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4
```
If device-overlay via /sys/kernel/config/device-tree access is not required, you can use mainline linux as well.

```bash
git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
-- or --
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.8.tar.xz; tar xvf linux-5.15.8.tar.xz
cd linux-5.15.8
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- socfpga_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4
```
configfs based device-tree overlay maybe enabled via https://github.com/ikwzm/dtbocfg on mainline linux (not tested).

Build img
=============================

#### 1. Create build directory, and run CMake against socfpga_debian (this) directory

```bash
mkdir $SOCFPGA/build
cd $SOCFPGA/build
cmake -DKERNELRELEASE="5.15.8" $SOCFPGA/socfpga_debian
```
The success of the cmake command creates a Makefile in the build directory.  You can find a list of make sub-commands by typing `make help.`
(The default KERNELRELEASE is defined in `$SOCFPGA/config.cmake` file)

#### 2. Run 'make' (or `make rootfs`) will create Debian root file system.  
This process requires root privilege due to elevated commands is in script files.  The 'root file system' generation process needs two steps; You need to enter two lines of commands when prompted.
```bash
$ sudo chroot /home/toshi/src/de0-nano-soc/build/arm-linux-gnueabihf-rootfs-buster
$ distro=buster /debootstrap.sh --second-stage
```
After 'root file system' was created, then

#### 3. Run 'make img' to make an SD Card image file.  
This step also requires root privilege for the 'sudo' command.
#### Don't forget to run `make umount` for unmounting loop devices used to generate file system images.

Boot `de0-nano-soc` with newly prepared SDCard
=============================

1. Using dd command, copy generated img file to SDCard.
```bash
dd if=socfpga_buster-5.15.8-dev.img of=/dev/sdX bs=1M; sync; sync; sync
```
1. Set SDCard to `de0-nano-soc`
1. Connect USB cable to `de0-nano-soc`
1. And, connect terminal using `screen /dev/ttyUSB0 115200`, and then power on.
1. You can login as root without password
1. Initial SDCard allocates only 2.5GB image, it can be expanded to full SDCard size by executing `/root/resizefs.sh` script, and reboot.

At this moment, no FPGA configuration has applied.  At this moment, no FPGA configuration has been applied yet.  Continue to process [socfpga_modules](https://github.com/qtplatz/socfpga_modules) for it.

