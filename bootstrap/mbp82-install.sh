#!/bin/sh

set -e
set -u

HD=/dev/sda
BOOTDEV=${HD}1
ROOTDEV=${HD}2
CRYPT=cryptroot
CRYPTDEV=/dev/mapper/$CRYPT

MIRROR=http://mirror.archlinux.no
HOSTNAME=myhost
TIMEZONE=Europe/Oslo

CUSTOM_MIRROR_NAME=mymrepo
CUSTOM_MIRROR_URL=http://myrepo.myhost.tld

# Disk setup

sgdisk -Z $HD
sgdisk -n 1:0:+256M $HD
sgdisk -n 2:0:0 $HD
sgdisk -t 1:ef00 $HD
sgdisk -t 2:8300 $HD
sgdisk -c 1:bootefi $HD
sgdisk -c 2:root $HD

mkfs.vfat -s2 -F32 $BOOTDEV

modprobe dm-crypt
cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 \
  --iter-time 5000 --use-random --verify-passphrase luksFormat $ROOTDEV
cryptsetup open $ROOTDEV $CRYPT
mkfs.btrfs $CRYPTDEV

mount $CRYPTDEV /mnt
mkdir /mnt/boot
mount $BOOTDEV /mnt/boot

echo "Server = $MIRROR/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
pacstrap /mnt \
  bash \
  btrfs-progs \
  bzip2 \
  coreutils \
  cronie \
  cryptsetup \
  device-mapper \
  dhcpcd \
  diffutils \
  dosfstools \
  file \
  filesystem \
  findutils \
  gawk \
  gcc-libs \
  gettext \
  glibc \
  grep \
  grub \
  gummiboot \
  gzip \
  inetutils \
  iproute2 \
  iputils \
  less \
  licenses \
  linux \
  logrotate \
  man-db \
  man-pages \
  openssh \
  pacman \
  pciutils \
  perl \
  procps-ng \
  psmisc \
  sed \
  shadow \
  sysfsutils \
  tar \
  texinfo \
  usbutils \
  util-linux \
  vi \
  which

genfstab -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt <<ENDCHROOT
sed -i 's/\(filesystems keyboard\) fsck/encrypt \1/' /etc/mkinitcpio.conf
mkinitcpio -p linux

umount /sys/firmware/efi/efivars
modprobe -r efivars
modprobe efivarfs
mount-t efivarfs efivarfs /sys/firmware/efi/efivars
gummiboot install
cat > /boot/loader/entries/radeon.conf <<EOF
title radeon (efi_stub)
linux /vmlinuz-linux
initrd /initramfs-linux.img
options cryptdevice=$ROOTDEV:$CRYPT root=$CRYPTDEV ro quiet init=/usr/lib/systemd/systemd libahci.ignore_sss=1 elevator=noop
EOF
cat > /boot/loader/entries/i915.conf <<EOF
title i915 (grub)
efi   \EFI\grub\grubx64.efi
EOF
echo 'default i915' > /boot/loader/loader.conf

sed -i '/set gfxmode/ a\  outb 0x728 1\n  outb 0x710 2\n  outb 0x740 2\n  outb 0x750 0' /etc/grub.d/00_header
sed -i 's/\(GRUB_TIMEOUT=\)5/\10/' /etc/default/grub
sed -i 's#\(GRUB_CMDLINE_LINUX="\)#\1cryptdevice=/dev/sda2:cryptroot init=/usr/lib/systemd/systemd i915.lvds_channel_mode=2 i915.lvds_use_ssc=0 libahci.ignore_sss=1 elevator=noop#' /etc/default/grub
sed -i 's/#\(GRUB_DISABLE_LINUX_UUID=true\)/\1/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot --boot-directory=/boot --bootloader-id=grub || true

ln -s /usr/lib/systemd/system/sshd.socket /etc/systemd/system/sockets.target.wants/sshd.socket
ENDCHROOT

umount /mnt/{boot,home,/sys{/firmware/efi/efivars,}}
