#!/bin/sh

set -e

USBDEV=/dev/sdb
RELEASE=2013.08.01
MIRROR=http://archlinux.limun.org
ISO=archlinux-$RELEASE-dual.iso

curl $MIRROR/iso/$RELEASE/$ISO > /tmp/$ISO

gdisk $USBDEV <<EOF
n



0700
w
Y
EOF

mkdir -p /mnt/{usb,iso}
mount -o loop /tmp/$ISO /mnt/iso
awk 'BEGIN {FS="="} /archisolabel/ {print $3}' \
  /mnt/iso/loader/entries/archiso-x86_64.conf \
  | xargs mkfs.vfat -F32 $USBDEV1 -n
mount $USBDEV1 /mnt/usb

cp -a /mnt/iso/* /mnt/usb
sync

umount /mnt/{usb,iso}
rmdir /mnt/{usb,iso}
rm /tmp/$ISO
