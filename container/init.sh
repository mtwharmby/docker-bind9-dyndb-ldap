#!/bin/bash

# If container started with `docker run --init` we don't need to start tini
if [ ! -x "/dev/init" ]; then
    exec /usr/bin/tini --
fi