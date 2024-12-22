#!/bin/bash

if [ ! -d "/var/kernel/cgroup2" ]; then
    mkdir -p /var/kernel/cgroup2
fi
mountpoint -q /var/kernel/cgroup2 || mount -t cgroup2 nodev /var/kernel/cgroup2
