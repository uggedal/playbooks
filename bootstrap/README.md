Bootstrap
=========

Most hosts needs some manual bootstrap before Ansible can take over managing
them.

Linode
------

1. Create a new VM with Arch Linux and boot it.
2. SSH into it and execute the following:

    ```sh
    curl -LO https://github.com/uggedal/playbooks/raw/master/bootstrap/linode.sh
    vi linode.sh
    sh linode.sh
    ```

3. Edit the configuration profile and change the kernel to `pv-grub-x86_64`.
4. Reboot.
5. Copy your ssh public key to the new VM:

    ```sh
    ssh-copy-id root@yourhost
    ```

6. Provision the host with ansible:

    ```sh
    ./play
    ```

MacBook Pro 8,2
---------------

1. Create a bootable USB disk:

    ```sh
    curl -LO https://github.com/uggedal/playbooks/raw/master/bootstrap/mbp82-usb.sh
    vi mbp82-usb.sh
    sh mbp82-usb.sh
    ```

2. Boot while holding down Option/Alt and select the USB disk.
3. Install the base system and type a password for encrypting the root device:

    ```sh
    curl -LO https://github.com/uggedal/playbooks/raw/master/bootstrap/mbp82-install.sh
    vi mbp82-install.sh
    sh mbp82-install.sh
    ```

4. Set a root password:

    ```sh
    passwd
    ```

4. Reboot.
5. Copy your ssh public key to the machine:

    ```sh
    ssh-copy-id root@yourhost
    ```

6. Provision the host with ansible:

    ```sh
    ./play
    ```
