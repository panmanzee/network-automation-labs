# Lab environment

Host: `pan-homeserver`, Ubuntu Server, i5-4570T, 8 GB RAM. Administered over SSH
only — no console/IPMI (see repo-root network-safety notes and `/home/pan/CLAUDE.md`).
Laptop runs the GNS3 GUI at `192.168.0.100`.

**Host IP is not pinned** — `eno1` has been both `.101` and `.102` via DHCP. Set
a router DHCP reservation for its MAC and use that address everywhere. Current: `192.168.0.101`.

## GNS3

- `gns3server` **2.2.61** (`gns3-server` pkg, `resolute` build), `dynamips`
  0.2.24, `ubridge` 1.0.1. Runs as the `systemd` unit `gns3server`, listening on
  `0.0.0.0:3080`. **API is v2** (`/v2/version`) — not v3.
- The GNS3 **GUI on the laptop must be exactly 2.2.61** (gns3.com → older releases).
- Config: `/etc/gns3/gns3_server.conf` (`640 gns3:gns3` — read with `sudo`).
  Auth on, user `gns3`; console ports 5000–5999.
- Get the server password: `sudo grep '^password' /etc/gns3/gns3_server.conf`.

## Management network

`br-gns3mgmt` — host-only bridge, `10.10.10.1/24`, applied via netplan
(`setup/br-gns3mgmt.yaml` → `/etc/netplan/99-br-gns3mgmt.yaml`). Not bridged to
`eno1`. Devices use `10.10.10.11+`.

## Firewall

`setup/ufw-rules.sh <LAPTOP_IP>` — allows 22 (SSH) from anywhere, and 3080 +
5000-5999 only from the laptop.

## Virtualization

The host is administered over SSH with no physical/BIOS access, so VT-x cannot be
enabled. `grep -c -w vmx /proc/cpuinfo` = `0`.

**Consequence:** everything runs on **Dynamips only** (no KVM/QEMU-accelerated
images). Routers = `c7200`; L2/L3 switching = `c3745` + `NM-16ESW` EtherSwitch
module. IOSvL2 is not used. This covers all CCNA 200-301 switching topics
(VLANs, trunking, STP, EtherChannel, SVIs, DHCP relay, HSRP) with the caveat
that the c3745 runs IOS 12.4 and the EtherSwitch has 16 ports / no L3
QoS features — acceptable for this portfolio.

## IOS images

| File | MD5 | Role | GNS3 template | idle-PC |
|------|-----|------|---------------|---------|
| c7200 adventerprisek9 15.x `.image` | _(fill)_ | router | `c7200` | _(fill)_ |
| c3745 12.4 `.image` | _(fill)_ | switch (NM-16ESW) | `c3745-esw` | _(fill)_ |

Switch path: **c3745 + NM-16ESW** (no VT-x — see Virtualization above).

## Toolchain verified

_(filled in Task 12 Step 7: date, gns3server version, GUI version, VT-x state,
pubkey-SSH works?, `ansible-playbook smoke.yml` result)_
