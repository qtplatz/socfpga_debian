#@ Makefile

all: boot.scr

boot.scr: boot.cmd
	mkimage -C none -A arm -T script -d boot.cmd boot.scr
