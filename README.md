=====
de0-nano-soc debian SD Card image generator
=====

This project contains cmake and dependent bash scripts for de0-nano-soc debian boot SD-Card.

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

Under the project directory (socfpga_debian), create build directory 'mkdir build', and change directory in it.
Run cmake as 'cmake <socfpga_debian-directory>'.  

Makefile will be generated, then run 'make' will create Debian root file system.  This process requires root privilege due to elevated command is in script files.

After 'rootfs' was created, run 'make img' to make SD Card image file.  This step also requires root privilege for 'sudo' command.

