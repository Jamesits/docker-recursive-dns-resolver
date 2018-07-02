#!/usr/bin/env bash
set -eu

# check if IPv6 is available in container
if grep -q 1 /proc/sys/net/ipv6/conf/all/disable_ipv6; then
    echo "Warning: IPv6 is not available in container." >&2
fi

echo "Bootstraping environment..."

# populate DNS root key if already available as package
if [ -f /usr/share/dns/root.key ]; then
    echo "Populating DNS root key..."
    cp -f /usr/share/dns/root.key /config/knot-resolver/root.key
fi

# try populate root hints
curl -sSL https://www.internic.net/domain/named.root -o /config/knot-resolver/named.root

echo "" > /etc/resolv.conf
echo "DNS configuration for bootstrap:"
echo $BOOTSTRAP_DNS_SERVER | sed -e "s/,/\n/g" | sed -e "s/^/nameserver /g" | tee /etc/resolv.conf

exec "$@"
