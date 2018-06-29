#!/usr/bin/env bash
set -eu

rm -f /etc/resolv.conf
echo "DNS configuration for bootstrap:"
echo $BOOTSTRAP_DNS_SERVER | sed -e "s/,/\n/g" | sed -e "s/^/nameserver /g" | tee /etc/resolv.conf

exec "$@"
