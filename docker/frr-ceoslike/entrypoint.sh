#!/bin/sh
# Start sshd (so Ansible network_cli can reach vtysh), then hand off to FRR's
# own init, which stays in the foreground.
set -e

mkdir -p /var/run/sshd /run/frr
chown frr:frr /run/frr 2>/dev/null || true

# host keys (also baked at build time; this covers a fresh volume)
[ -f /etc/ssh/ssh_host_ed25519_key ] || ssh-keygen -A

/usr/sbin/sshd

# hand off to the stock FRR container entrypoint (path confirmed in Step 2:
# base image CMD is /usr/lib/frr/docker-start)
exec /usr/lib/frr/docker-start
