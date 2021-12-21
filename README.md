de0-nano-soc debian 10/11 SD card image generator.
=====

This project contains cmake and dependent bash scripts for de0-nano-soc debian boot SD-Card.

Prerequisite
===============

1. Linux (debian 10 buster or 11 bullseye) host (amd64).
2. Multiarch for armhf enabled on host.
3. QEMU arm

Dependent debian packages
===========================

```
sudo dpkg --add-architecture armhf
sudo apt-get -y install crossbuild-essential-armhf
sudo apt-get -y install build-essential bc libncurses5-dev cmake dkms git
sudo apt-get -y install flex bison u-boot-tools
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

The most effortless procedure is to obtain a kernel source from Debian to avoid kernel-header issues discussed later.  This only works if your target and your build host use the same Debian version.  Use 'apt source linux` command to get source package.

Option 1. Obtain from Debian source package
```bash
$ cd $SOCFPGA
$ apt source linux
$ KERNELRELEASE=5.10.84 # <-- this number should be modified, whil will refer later
```

Option 2. Obtain from the Altera provided git-repo, which support device-tree overlay.
```bash
$ git clone https://github.com/altera-opensource/linux-socfpga
$ KERNELRELEASE= X.XX.XX # <-- X.XX.XX should set for later reference
```
Option 3. Obtain from the kernel.org
```bash
KERNELRELEASE=5.15.10
$ wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KERNELRELEASE}.tar.xz
$ tar xvf linux-${KERNELRELEASE}.tar.xz
```

Linux kernel can configure the "socfpga" target by following three lines of commands.  It will generate a file `zImage`.

```bash
cd linux-${KERNELRELEASE}
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- socfpga_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4
```

The kernel supported by Altera only be able to configure with device-tree overlay via `/sys/kernel/config/device-tree` interface.

### Quick dirty fix for `scripts/basic/fixdep: Exec format error`

> The dynamic module configuration (DKMS) need a Linux-header module installation, which can generate by the following command;
```bash
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4 deb-pkg
```
> However, the built .deb package contains amd64 binary that causes an error of `scripts/basic/fixdep: Exec format error` when install dkms driver module on the target device.  Indeed, fixdep is compiled with HOSTCC, which is amd64 binary.  An attempt to rebuild by "make scripts" on /usr/src/linux-XX-headers directory caused "no Kconfig found" error.  

Quick dirty hack of this hell is as follows:

1. Make a full copy of linux-kernel build directory to the /usr/src directory on the target device
```bash
$ cd ${SOCFPGA}/${KERNELRELEASE}; make clean
$ cd ..
$ tar -acvf linux-${KERNELRELEASE}.tar.xz ./linux-${KERNELRELEASE}
```
2. Make (or replace) symbolic link bellow
```bash
nano # cd cd /lib/modules/$(uname -r)
nano # ln -s /usr/src/linux-$(uname -r) source
nano # ln -s /usr/src/linux-$(uname -r) build
```
You can install the header module via apt-get if you pick the kernel release from one of the official Debian distributions.  You also have to make a symbolic links corresponding to above.

> The symbolic links can be created on the `rootfs` or `img` file will create on the next section.
> Easy way is make a copy to `rootfs`, which is usual directory tree on the Linux.

Build img
=============================

#### 1. Create build directory, and run CMake against socfpga_debian (this) directory

```bash
$ distro=bullseye
$ mkdir $SOCFPGA/build-${distro}
$ cd $SOCFPGA/build-${distro}
$ cmake -DKERNELRELEASE=${KERNELRELEASE} -Ddistro=${distro} $SOCFPGA/socfpga_debian
```
The success of the cmake command creates a Makefile in the build directory.  You can find a list of make sub-commands by typing `make help.`

#### 2. Run 'make' (equivalent to `make rootfs`) will create Debian root file system.
This process requires root privilege due to elevated commands is in script files.  The 'root file system' generation process needs two steps; You need to enter two lines of commands when prompted.
```bash
$ sudo chroot /home/toshi/src/de0-nano-soc/build/arm-linux-gnueabihf-rootfs-buster
$ distro=buster /debootstrap.sh --second-stage
```
After `rootfs` was created, then

#### 3. Run 'make img' to make an SD Card image file.

This step also requires root privilege for the 'sudo' command.

Boot `de0-nano-soc` with newly prepared micro SD Card
=============================

1. Using dd command, copy generated img file to micro SD Card.
```bash
dd if=socfpga_buster-${KERNELRELEASE}.img of=/dev/sdX bs=1M; sync
```

1. Set SDCard to `de0-nano-soc`
1. Connect USB cable to `de0-nano-soc`
1. And, connect terminal using `screen /dev/ttyUSB0 115200`, and then power on.
1. You can login as root without password
1. Initial SDCard allocates only 2.5GB image, it can be expanded to full SDCard size by executing `/root/resizefs.sh` script, and reboot.

At this moment, no FPGA configuration has applied.  At this moment, no FPGA configuration has been applied yet.  Continue to process [socfpga_modules](https://github.com/qtplatz/socfpga_modules) for it.
