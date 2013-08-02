Playbooks
=========

[Ansible][a] playbooks for [uggedal.com][u]. Developed for Arch Linux.

Inventory
---------

Inventory hosts file and variables are kept private. To use these
playbooks you'll need to create your own hosts file before you can run
`ansible-playbook` with:

```sh
ansible-playbook -i ../private-inventory/hosts site.yml
```

### Groups

The `servers` and `laptops` groups are used to differente behavior
within some roles:

#### ntp

`servers` will strart and enable the `ntpd` service while `laptops` will
enable and run the `ntpdate` *oneshot* service on boot.

### Variables

By creating `group_vars` and `host_vars` files relative to the hosts file
you can provide the following variables:

#### ansible

Under Arch Linux `/usr/bin/python` is Python 3 so you'll need to tell
ansible where Python 2 is located:

```yml
ansible_python_interpreter: /usr/bin/python2
```

#### systemd

##### timezone

Your timezone as found in `/usr/share/zoneinfo`.

```yml
systemd_timezone: Europe/Oslo
```

##### locales

A list of available locales. Set `default` to `true` for your default locale.

```yml
systemd_locales:
 - name: en_US.UTF-8
   charset: UTF-8
   default: true
 - name: nb_NO.UTF-8
   charset: UTF-8
   default: false
```

##### journal max size

Set an upper file size for the systemd journal.

```yml
systemd_journal_max_size: 100M
```

##### logind ignore lid switch

Set to `true` if you want closing the lid of your laptop to be a noop.

```yml
systemd_logind_ignore_lid_switch: true
```

#### pacman

##### repos

A list of custom pacman repositories. The package signature level will be
optional for these.

```yml
pacman_repos:
  - name: myrepo
    url: http://repo.myhost.com
```

##### mirrors

A list of mirrors for the official pacman repos.

```yml
pacman_mirrors:
  - https://mirrors.kernel.org/archlinux/
```

#### ssh

```yml
ssh_allow_users:
  - root
```

#### iptables

```yml
iptables_accept_tcp:
  - port: 80
    source: null      # Allow from all sources
  - port: 22
    source: limit     # Limit to 10 connections within 30 seconds
  - port: 25
    source: 127.0.0.1 # Allow only from the given source
```

#### dhcp

```yml
dhcp_interface: eth0
```

#### pam

```yml
pam_limits_nofile: 50000
```

#### uwsgi

```yml
uwsgi_user: http
uwsgi_services:
  - name: mysite
    module: "mysite:app"
    processes: 4
  - name: myothersite
    module: myothersite
    django: true
    idle: true
    processes: 1
```

#### nginx

```yml
nginx_worker_user: http
nginx_worker_processes: 2
nginx_sites:
  - fqdn: mysite.com
    aliases:
      - www.mysite.com
    default: true
    root: /srv/http/mysite
    uwsgi: true
    upstreams: ["unix:/var/run/uwsgi/mysite.sock"]
    static_prefix: /static
```

License
-------

MIT

[a]: http://ansibleworks.com/
[u]: http://uggedal.com/
