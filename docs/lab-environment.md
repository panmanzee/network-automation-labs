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

`grep -c -w vmx /proc/cpuinfo` = `<fill: 0 = VT-x off, use c3745+NM-16ESW switch
fallback; >0 = IOSvL2 available>`.

## IOS images

| File | MD5 | Role | GNS3 template | idle-PC |
|------|-----|------|---------------|---------|
| _(filled in Task 6–7)_ | | | | |

Switch path in use: `<IOSvL2 | c3745+NM-16ESW>` — reason: `<VT-x availability>`.

## Toolchain verified

_(filled in Task 12 Step 7: date, gns3server version, GUI version, VT-x state,
pubkey-SSH works?, `ansible-playbook smoke.yml` result)_
