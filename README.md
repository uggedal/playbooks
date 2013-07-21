Playbooks
=========

[Ansible][a] playbooks for [uggedal.com][u]. Developed for Arch Linux.

Bootstrap
---------

### Linode

1. Create a new VM with Arch Linux and boot it.
2. SSH into it and execute the following:
   ```shell
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

   # Install distro kernel
   pacman -Su --noconfirm
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
  ```

[a]: http://ansibleworks.com/
[u]: http://uggedal.com/
