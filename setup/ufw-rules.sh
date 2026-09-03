#!/usr/bin/env bash
# Least-privilege firewall for the GNS3 server.
# Usage: sudo ./ufw-rules.sh <LAPTOP_IP>
# Only the laptop reaches the API (3080) and consoles (5000-5999); SSH stays open.
set -euo pipefail
LAPTOP_IP="${1:?pass the laptop IP, e.g. sudo ./ufw-rules.sh 192.168.0.100}"

# SSH-only host with no console. Open SSH BEFORE enabling ufw, and keep it open
# from anywhere (not just the laptop) so a laptop-IP change can't lock you out.
ufw allow OpenSSH
ufw show added | grep -qi 'OpenSSH' || { echo "SSH rule missing - aborting"; exit 1; }
ufw allow from "$LAPTOP_IP" to any port 3080 proto tcp      comment 'gns3 api'
ufw allow from "$LAPTOP_IP" to any port 5000:5999 proto tcp comment 'gns3 consoles'
ufw --force enable
ufw status verbose
