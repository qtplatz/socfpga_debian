#!/bin/bash

resize_partition() {
    echo "Resizing"
    fdisk $1 <<EOF>/dev/null
d
2
n
p
2
131072

w
EOF
}

echo "reading current partition..."
sudo fdisk -l

resize_partition /dev/mmcblk0
sudo fdisk -l $1

cp -p /etc/rc.local /etc/rc.local.orig

cat <<EOF>/etc/rc.local
#!/bin/sh -e
resize2fs /dev/mmcblk0p2
rm -f \$0
mv /etc/rc.local.orig /etc/rc.local
EOF
chmod 0755 /etc/rc.local
rm -f $0
echo "=============================="
echo "  You should reboot now.  "
echo "=============================="

