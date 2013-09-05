#!/bin/sh

set -e

# Remove unneeded packages
pacman -Rs --noconfirm \
  cryptsetup \
  heirloom-mailx \
  jfsutils \
  lvm2 \
  mdadm \
  nano \
  netctl \
  reiserfsprogs \
  xfsprogs

# Upgrade system
pacman -Syu

# Upgrade firmware
pacman -S --noconfirm git binutils
curl -s https://raw.github.com/Hexxeh/rpi-update/master/rpi-update | bash
pacman -Rs --noconfirm git binutils

# Remove unneeded package files
pacman -Sc --noconfirm

# Install essentials
pacman -S omxplayer-git ttf-freefont python2
