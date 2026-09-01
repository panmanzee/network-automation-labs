# CCNA GNS3 Lab Portfolio

Hands-on Cisco networking labs built in GNS3 with real IOS, each documented as a
solved scenario: topology, full device configs, verification output, and a
short write-up of what it demonstrates.

Design: [`docs/`](docs/) · Environment setup: [`docs/lab-environment.md`](docs/lab-environment.md)

## Labs

| # | Lab | Topics | Status |
|---|-----|--------|--------|
| 01 | Campus L2 | VLANs, 802.1Q trunking, RSTP root tuning, LACP EtherChannel | planned |
| 02 | Inter-VLAN + services | L3-switch SVIs, DHCP relay, HSRP failover | planned |
| 03 | OSPF multi-area | areas, DR/BDR, MD5 auth, ABR summarisation | planned |
| 04 | Edge & security | NAT/PAT, standard + extended ACLs, SSH hardening | planned |
| 05 | Operations | NTP, Syslog, SNMPv3, config archive | planned |

## Skills matrix

_Filled in as labs are completed — maps each lab to CCNA 200-301 exam topics._

## How it works

- `gns3server` runs headless on a mini PC; the GNS3 GUI runs on a laptop.
- Every device attaches to an out-of-band management network (`10.10.10.0/24`).
- Each lab ships an Ansible layer: `deploy.yml` pushes the configs,
  `verify.yml` asserts the expected state and captures the evidence.

## Reproduce

See [`docs/lab-environment.md`](docs/lab-environment.md) for the full setup, then
per lab: import the GNS3 project, `ansible-playbook labs/<lab>/deploy.yml`,
`ansible-playbook labs/<lab>/verify.yml`.

## License

MIT for scripts and playbooks; CC-BY-4.0 for the written lab guides.
