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

##### python interpreter

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

##### allow users

Give a list of users which should be able to ssh to a host.

```yml
ssh_allow_users:
  - root
```

#### iptables

##### accept

A list of rules to accept connections for where:

* `port` is self-explanatory
* `proto` can be `udp` or `tcp`
* `source` can be:
    - `null` to allow connections from all sources
    - `limit` to limit per client to 10 connections within 30 seconds
    - an ip/netmask to restrict where connections can come from

```yml
iptables_accept:
  - port: 80
    proto: tcp
    source: null
  - port: 22
    proto: tcp
    source: limit
  - port: 25
    proto: tcp
    source: 127.0.0.1
  - port: 123
    proto: udp
    source: null
```

#### dhcp

##### interface

Which interface under `/dev` to bring up with `dhcpcd`.

```yml
dhcp_interface: eth0
```

#### pam

##### limits nofile

PAM `ulimit(1)` setting for hard and soft limit of number of open files.

```yml
pam_limits_nofile: 50000
```

#### uwsgi

##### user

The uid and gid uwsgi should drop privileges to.

```yml
uwsgi_user: http
```

##### services

A list of uwsgi services to configure and start where:

* `name`: a unique identifier
* `module`: the WSGI module uwsgi should start
* `processes`: number of workers uwsgi should start (defaults to 2)
* `django`: should be set to `true` for Django projects
* `chdir`: a directory to `chdir(3)` to before starting the app
* `idle`: set to `true` to make uwsgi idle after 60 seconds of inactivity
* `global`: set to `true` if you don't want to load the app from a virtualenv

Note that a package with `name` will be installed for each uwsgi service
item. If `global` is not set it's assumed that a virtualenv with the
app installed is living under `/usr/local/venv`.

```yml
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

##### worker user

```yml
nginx_worker_user: http
```

##### worker processes

```yml
nginx_worker_processes: 2
```

##### sites

```yml
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
