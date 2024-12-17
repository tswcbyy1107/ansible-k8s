#!/bin/bash

set -eu

nice_value="-20"

for pid in $(pgrep -u root '^ksoftirqd/[0-9]+$'); do
    chrt -o -p 0 "$pid"
    renice -n "$nice_value" -p "$pid"
done
