#!/bin/sh

set -e

# Fix root fs mount options
sed 's/rw,relatime,errors=continue,barrier=0,data=writeback/defaults,noatime,barrier=0/' -i /etc/fstab

# Select the closest/fastest pacman mirror
echo 'Server = https://archlinux.limun.org/$repo/os/$arch' > /etc/pacman.d/mirrorlist

# Initialize pacman keyring
pacman -Sy
sed 's/SigLevel    = Required DatabaseOptional/SigLevel = Never/' -i /etc/pacman.conf
pacman -S --noconfirm haveged
haveged -w 1024
pacman-key --init
pkill haveged
pacman -Rs --noconfirm haveged
sed 's/SigLevel = Never/SigLevel    = Required DatabaseOptional/' -i /etc/pacman.conf
pacman-key --populate archlinux

# Update system
pacman -Su --noconfirm

# Install distro kernel
pacman -S linux

# Create PV-GRUB config
mkdir -p /boot/grub
cat << 'EOF' > /boot/grub/menu.lst
timeout 0
default 0

title  Arch Linux  [/boot/vmlinuz-linux]
root   (hd0)
kernel /boot/vmlinuz-linux root=/dev/xvda ro ipv6.disable_ipv6=1 init=/usr/lib/systemd/systemd
initrd /boot/initramfs-linux.img
EOF

# Install Ansible dependency
pacman -S --noconfirm python2
