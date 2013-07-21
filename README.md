Playbooks
=========

[Ansible][a] playbooks for [uggedal.com][u]. Developed for Arch Linux.

Bootstrap
---------

### Linode

1. Create a new VM with Arch Linux and boot it.
2. SSH into it and execute the following:

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

[a]: http://ansibleworks.com/
[u]: http://uggedal.com/
