# bind9-dyndb-ldap

Bind9 DNS server with the bind-dyndb-ldap (https://pagure.io/bind-dyndb-ldap) backend driver. The image is based on Debian stable (slim).

## Configuration
`startup.sh` looks for the `named` config file at `/etc/bind/named.conf`. If none is found, it copies the default debian config to `/etc/bind` before starting the server. An `rndc.key` file is also generated if none is found. All files in the `/etc/bind` directory are owned by root and have the group bind (GID=101).

To use your own config, mount a volume containing `named.conf` at `/etc/bind`.

## LDAP Requirements
bind9-dyndb-ldap relies on *LDAP Content Syncronisation Operation* ([RFC 4533](https://tools.ietf.org/html/rfc4533)) to do runtime synchronisation of DNS records ([bind9-dyndb-ldap design docs](https://docs.pagure.org/bind-dyndb-ldap/BIND9/Design/LdapSynchronizationOverview.html)). On an OpenLDAP server, this requires the inclusion of the *syncprov* module in the server config - the module is distributed as part of the [slapd](https://packages.debian.org/stable/slapd) package on debian. The database containing the bind9-dyndb-ldap configuration and zone data also needs to be configured with the *syncprov overlay*. A sample OpenLDAP LDIF which adds the necessary values is included in the repository - [syncprov.ldif](syncprov.ldif) - have a look at the [zytrax.com](https://www.zytrax.com/books/ldap/ch6/syncprov.html) for an explanation of the options included in the LDIF.

To incorporate the changes:
```
$ ldapadd -x -H ldap://ldap-server-hostname -D "cn=admin,cn=config" -W -v -f syncprov.ldif
```
## Notes

### init Process:  tini
A Docker container does not start an init process internally to reap zombie processes. As `named` creates a number of additional processes, it is important to have an PID=1 process capable of reaping zombie or  orphaned processes (see [Docker and the PID 1 zombie reaping problem](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)). Docker allow passing the `--init` flag when running the container, but this isn't available for kubernetes. [`tini`](https://github.com/krallin/tini), used by Docker to proved init-like capabilities with the `--init` flag, is set as the ENTRYPOINT. Running the `/container/startup.sh` as a command leaves `named` processes running under the watchful eye of `tini`.

### Build Notes
This project is built with multi-arch support through the `buildx` plugin (https://github.com/docker/buildx). To use this the following steps are necessary (with Docker v19.03 +). These notes are as much for myself as anyone else!

1) [Install](https://github.com/docker/buildx#with-buildx-or-docker-1903 "buildx install notes"): 
    ```
    $ export DOCKER_BUILDKIT=1
    $ docker build --platform=local -o . git://github.com/docker/buildx
    $ mkdir -p ~/.docker/cli-plugins
    $ mv buildx ~/.docker/cli-plugins/docker-buildx
    ```
2) [Install `binfmt_misc` support](https://github.com/docker/buildx#building-multi-platform-images "buildx - building multi-platform images"):
    ```
    $ docker run --privileged --rm tonistiigi/binfmt --install all
    ```
3) [Create a specuific builder instance](https://docs.docker.com/docker-for-mac/multi-arch/#build-and-run-multi-architecture-images "docker - building multi-platform images"):
    ```
    $ docker buildx create --use --name mybuilder
    $ docker buildx inspect --bootstrap
    ```
    The latter command is only to check we have the additional archs available.

4) Build the image (this automatically uses the selected builder).
   1) If building for the local docker instance:
        ```
        $ docker buildx build --platform linux/amd64,linux/arm/v7 -t <username>/bind9-dyndb-ldap:latest -t <username>/bind9-dyndb-ldap:<ver> --output type=docker .
        ```
   2) If building to push to DockerHub (or wherever) you need to login before doing the build (e.g. `docker login`):
        ```
        $ docker buildx build --platform linux/amd64,linux/arm/v7 -t <username>/bind9-dyndb-ldap:latest -t <username>/bind9-dyndb-ldap:<ver> --push .
        ```
    The only difference between these commands are the arguments `--output type=docker` and `--push` (synonymous with `--output type=registry`) (see [buildx commandline docs](https://docs.docker.com/engine/reference/commandline/buildx_build/) for more options).


There seem to be ways to automate this process with Github/Gitlab... but I haven't investigated these:
- https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/ (in the "Let’s go to production" section)
- https://github.com/docker/buildx/issues/202#issuecomment-597375245

