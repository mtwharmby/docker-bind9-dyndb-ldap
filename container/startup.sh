#!/bin/sh -e

OPTIONS=""

if [ ! -s /etc/named.conf ]; then
    cp -ra /container/bind /etc/bind
fi
# Ensure there is an rndc.key.
# This was lifted from postinst script from debian 10 (buster)
# bind9_9.11.5.P4+dfsg-5.1+deb10u2_armhf.deb
if [ ! -s /etc/bind/rndc.key ] && [ ! -s /etc/bind/rndc.conf ]; then
	rndc-confgen -r /dev/urandom -a
fi

# Fix permisions & ownership (these are copied from a clean install)
chmod 644 /etc/bind/*
chmod 640 /etc/bind/rndc.key
chmod 2755 /etc/bind
chown -R root:bind /etc/bind

# Borrowed from the start function in /etc/init.d/bind from debian 10 (buster)
# bind9_9.11.5.P4+dfsg-5.1+deb10u2_armhf.deb
PIDFILE=/run/named/named.pid
mkdir -p /run/named
chmod 775 /run/named
chown root:bind /run/named >/dev/null 2>&1 || true

# Start command: hacked together from debian script again.
exec /usr/sbin/named --pidfile ${PIDFILE} -- $OPTIONS