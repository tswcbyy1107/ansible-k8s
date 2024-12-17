#!/bin/bash
# note: https://www.cnblogs.com/jianyungsun/p/12554455.html
set -eu

modprobe nf_conntrack
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=10
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_fin_wait=10
