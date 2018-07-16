=====
Nanopi-neo debian SD Card image generator
=====

This project contains cmake and dependent bash scripts for nanopi-neo debian boot SD-Card.

===============
 Prerequisite
===============

1. Linux (debian9) host (x86_64).
2. Multiarch for armhf enabled on host.
3. QEMU arm

===========================
 Dependent debian packages 
===========================

sudo dpkg --add-architecture armhf
sudo apt-get -y install crossbuild-essential-armhf
sudo apt-get -y install bc build-essential cmake dkms git libncurses5-dev
(May be some else...)

===========================
 Procedure
===========================

Run './bootstrap.sh' on project root directory.
Then, chdir to "../build-armhf/nanopi-neo.release/";

[1] Debootstrap debian package (only 1st time)
At beginning, we need a debian debootstrap'ed rootfs on local directory by typing: 'make debian'
It will generate debian rootfs under 'build-armhf/arm-linux-gnueabihf-rootfs-stretch' directory.
Debootstrap require post process in qemu-arm with chroot.  When you have prompt from the script,
follow the message.

[2] image file generation
As long as you have debian rootfs described above, then simply run 'make' will generate SDCard
image file 'nanopi-neo_streatch-<version_number>-dev.img' in working directory.

The rootfs included in .img file is a copy of debootstrap rootfs with additional installed packages.
See scripts/setup-debian-dev.sh script for details.

By default, scripts/setup-debian-dev.sh is installing build tools for native development.
Replace this scipt to setup-debian.sh for .img without build tools.

Good luck.



