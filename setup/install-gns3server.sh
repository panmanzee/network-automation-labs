#!/usr/bin/env bash
# Install a headless GNS3 server on Ubuntu. Run with sudo.
#   sudo ./install-gns3server.sh
# Then set a real password and enable the service (see the echoed hints).
set -euo pipefail

add-apt-repository -y ppa:gns3/ppa
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  gns3-server dynamips ubridge vpcs qemu-system-x86 qemu-utils

# gns3 service user + groups
id gns3 &>/dev/null || useradd -r -m -d /opt/gns3 -s /usr/sbin/nologin gns3
usermod -aG ubridge,kvm gns3 || true
mkdir -p /opt/gns3/images /opt/gns3/projects /etc/gns3
chown -R gns3:gns3 /opt/gns3

install -m 640 -o gns3 -g gns3 \
  "$(dirname "$0")/gns3_server.conf.example" /etc/gns3/gns3_server.conf
echo ">>> edit /etc/gns3/gns3_server.conf and set a real 'password' before enabling"

cat >/etc/systemd/system/gns3server.service <<'UNIT'
[Unit]
Description=GNS3 server
After=network-online.target
Wants=network-online.target

[Service]
User=gns3
Group=gns3
ExecStart=/usr/bin/gns3server --config /etc/gns3/gns3_server.conf
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
echo ">>> next:"
echo "    sudo sed -i \"s/password = CHANGE_ME/password = \$(openssl rand -hex 16)/\" /etc/gns3/gns3_server.conf"
echo "    sudo systemctl enable --now gns3server"
