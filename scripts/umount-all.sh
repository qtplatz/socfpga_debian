#!/bin/bash
# Copyright 2017-2022 (C) MS-Cheminformatics LLC
# Project supported by Osaka University Graduate School of Science
# Author: Toshinobu Hondo, Ph.D.
cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

detach=0

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		--detach)
			detach=1
			shift
			;;
		*)
			break
			;;
	esac
done

for i in "$@"; do
	echo "---------- unmounting $i"
	umount "$i"
done

if ((detach)); then
	${cwd}/detach-all.sh
fi

exit 0 # ignore error code
