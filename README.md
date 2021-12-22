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
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j`nproc`
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
$ KERNELRELEASE=`make -C linux-5.10.84 kernelversion` # <-- a value "5.10.84" need to be replaced with actual value.
```

Option 2. Obtain from the Altera provided git-repo, which support device-tree overlay.
```bash
$ git clone https://github.com/altera-opensource/linux-socfpga
$ KERNELRELEASE=`make -C linux-socfpga kernelversion`
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
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j`nproc`
```

The kernel supported by Altera only be able to configure with device-tree overlay via `/sys/kernel/config/device-tree` interface.

### Quick dirty fix for `scripts/basic/fixdep: Exec format error`

> The dynamic module configuration (DKMS) need a Linux-header module installation, which can generate by the following command;
```bash
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j`nproc` deb-pkg
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

#### 1. Create build directory, and run cmake against socfpga_debian (this) directory

```bash
$ distro=bullseye
$ mkdir $SOCFPGA/build-${distro}
$ cd $SOCFPGA/build-${distro}
$ cmake -DKERNELRELEASE=${KERNELRELEASE} -Ddistro=${distro} $SOCFPGA/socfpga_debian
```
The success of the cmake command creates a Makefile in the build directory.  You can find a list of make sub-commands by typing `make help.`

#### 2. Run 'make' (equivalent to `make rootfs`) will create Debian root file system.

It will generate a Debian rootfs (root file system) directory tree under the current directory with a top directory name of 'arm-linux-gnueabihf-rootfs-${distro}.'  This step takes a few minutes.  This process requires root privilege due to elevated commands being in script files.
After `rootfs` is created, copy and merge boot files and rootfs into a single .img file by the following step.

#### 3. Run 'make img' to make an SD Card image file.

This step also requires root privilege for the 'sudo' command.

#### 4. Optional steps

You have a .img file such as 'socfpga_bullseye-5.10.84.img', which is ready to copy to micro SD card for boot the SoC; however, it is a minimum set of files to boot SoC using standard device-tree provided from u-boot.  Of course, you can make a boot SD card image now and then add the FPGA configuration,  device-tree (.dtb), altered Linux boot file (zImage), and your application files to the target device after booting up.  In addition, you have an option where you can install all the above before .img copy to the micro SD card.  It would be handy to generate several micro SD cards ready to go with the application.

1. Run 'make mount' command will mount .img file under '/mnt/bootfs' and '/mnt/rootfs' folders of host system.  (Don't forget to run 'make umount' after necessary tasks are done.)
1. Do 'sudo chroot /mnt/rootfs' to access the target root filesystem with root privilege.  You can use almost all Linux shell commands, including apt-get and the dpkg commands.

Following is an example walkthrough to install socfpga_modules application setup.

```bash
## on build host (amd64)
$ cd ${SOCFPGA}/build-${distro)
$ make socfpga-modules	# <-- this command copies files from socfpga_modules (it must be built in advance)
$ make mount
$ sudo chroot /mnt/rootfs
# cd /root
# dpkg -i *dkms*.deb    # <-- install all kernel modules
# dpkg -i qtplatz-5.2.4.39-Linux-Runtime.deb         # <-- install qtplatz core libraries
# dpkg -i socfpga_modules-5.0.1.25-Linux-httpd.deb   # <-- sample httpd
# dpkg -i socfpga_modules-5.0.1.25-Linux-tools.deb   # <-- command line tools for testing
# exit
$ make umount          # <-- unmounting /mnt/bootfs and /mnt/rootfs
```

Boot `de0-nano-soc` with newly prepared micro SD Card
=============================

1. Using dd command, copy generated img file to micro SD Card.
```bash
dd if=socfpga_buster-${KERNELRELEASE}.img of=/dev/sdX bs=1M; sync
```

2. Set SDCard to `de0-nano-soc`
3. Connect USB cable to `de0-nano-soc`
4. And, connect terminal using `screen /dev/ttyUSB0 115200`, and then power on.
5. You can login as root without password
6. Initial SDCard allocates only 2.5GB image, it can be expanded to full SDCard size by executing `/root/resizefs.sh` script, and reboot.

At this moment, no FPGA configuration has applied.  At this moment, no FPGA configuration has been applied yet.  Continue to process [socfpga_modules](https://github.com/qtplatz/socfpga_modules) for it.

After boot up
=============================

1. The file system utilizes 4 GB on the micro SD card.  You can run '/root/resizefs.sh` script and reboot that will be expanding file system size to a maximum of physical micro SD card.

1. Network is configured with traditional ifup/ifdown (not the modern NetworkManager).  You can change IP address (DHCP by default) by editing /etc/network/interface file.

1. In case you have socfpga_modules installed, you can access SoC from web broswer by "http://<target ip addr>/"

1. You can also test ADC via a command "/usr/local/bin/adc -c 99" etc.

END-of-FILE
