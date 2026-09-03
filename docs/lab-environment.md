# Lab environment

Host: `pan-homeserver` (192.168.0.102), Ubuntu Server, i5-4570T, 8 GB RAM.
Laptop runs the GNS3 GUI (DHCP-reserved IP, e.g. `192.168.0.100`).

## GNS3

- `gns3server` `<VERSION — fill from Task 3 Step 4>`, installed from `ppa:gns3/ppa`
  via `setup/install-gns3server.sh`, runs as the `systemd` unit `gns3server`.
- The GUI on the laptop **must be the same version**.
- Config: `/etc/gns3/gns3_server.conf` (see `setup/gns3_server.conf.example`).
  Auth on; console ports 5000–5999.

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
