#!Makefile
# Copyright 2017-2018 (C) MS-Cheminformatics LLC
# Project supported by Osaka University Graduate School of Science
# Author: Toshinobu Hondo, Ph.D.

DISTRO    = 
TARGETDIR = ../arm-linux-gnueabihf-rootfs-${DISTRO}

all:
	@echo "-- run 'make world' to build debian rootfs"

world:
	targetdir=${TARGETDIR} distro=${DISTRO} ./debootstrap.sh

clean:
	sudo rm -rf ${TARGETDIR}

