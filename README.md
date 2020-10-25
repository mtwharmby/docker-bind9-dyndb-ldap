# bind9-dyndb-ldap

Bind9 DNS server with the bind-0dyndb-ldap (https://pagure.io/bind-dyndb-ldap) backend driver. The image is based on Debian stable (slim).

## Configuration
`startup.sh` looks for the `named` config file at `/etc/bind/named.conf`. If none is found, it copies the default debian config to `/etc/bind` before starting the server. An `rndc.key` file is also generated if none is found. All files in the `/etc/bind` directory are owned by root and have the group bind (GID=101).

To use your own config, mount a volume containing `named.conf` at `/etc/bind`.