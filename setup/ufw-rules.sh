#!/usr/bin/env bash
# Least-privilege firewall for the GNS3 server.
# Usage: sudo ./ufw-rules.sh <LAPTOP_IP>
# Only the laptop reaches the API (3080) and consoles (5000-5999); SSH stays open.
set -euo pipefail
LAPTOP_IP="${1:?pass the laptop IP, e.g. sudo ./ufw-rules.sh 192.168.0.100}"

ufw allow OpenSSH                                              # never lock ourselves out
ufw allow from "$LAPTOP_IP" to any port 3080 proto tcp      comment 'gns3 api'
ufw allow from "$LAPTOP_IP" to any port 5000:5999 proto tcp comment 'gns3 consoles'
ufw --force enable
ufw status verbose
