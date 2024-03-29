#!/bin/bash
# Copyright 2017-2022 (C) MS-Cheminformatics LLC
# Project supported by Osaka University Graduate School of Science
# Author: Toshinobu Hondo, Ph.D.

count=`sudo losetup | grep "/dev/loop[0-9]" |wc -l`
echo "$(basename $0) detach loop devices: " $count " device(s) found"

while ((count)); do
    count=$((count-1))
    echo losetup -d /dev/loop$((count))
    sudo losetup -d /dev/loop$((count))
done
