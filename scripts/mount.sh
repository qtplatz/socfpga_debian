#/bin/sh
# Copyright 2017-2018 (C) MS-Cheminformatics LLC
# Project supported by Osaka University Graduate School of Science
# Author: Toshinobu Hondo, Ph.D.

if [ $# -ne 1 ]; then
    echo "$0 image.img"
    exit
fi

sudo losetup --show -f -P $1
