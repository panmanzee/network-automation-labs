# Lab environment

Host: `pan-homeserver`, Ubuntu Server, i5-4570T, 8 GB RAM. Administered over
SSH only — no console/IPMI (see `/home/pan/CLAUDE.md` network-safety rules).
Host IP: `192.168.0.101` (DHCP-reserved for MAC `00:23:24:77:4f:53`).

Docker is already installed and in use (newsfeed stack: postgres, n8n,
newsfeed-api). Containerlab reuses the same Docker daemon; labs get their own
isolated network and don't touch the newsfeed containers.

## Containerlab

- Installed as a single static Go binary in `~/.local/bin/containerlab` (no
  sudo needed to install; `sudo` **is** needed to `deploy`/`destroy`, since
  Containerlab creates network namespaces and veth pairs).
- Version: `0.79.0`.
- Every `deploy`/`destroy` is run by the human from the repo root, e.g.:
  `sudo containerlab deploy -t smoke/topology.clab.yml`.

## Arista cEOS-lab

- Free image, registered at arista.com (Arista Portal → Software Download →
  cEOS-lab). A personal email is normally accepted (purpose: "self-study").
  **Never commit the image itself** — it's imported locally with `docker
  import` and referenced by tag in each `topology.clab.yml`.
- Version / imported tag: _(filled in Task 9)_.
- ~85% CLI overlap with Cisco IOS for CCNA-relevant topics; VLANs, trunking,
  RSTP, LACP, OSPF, ACLs, VRRP are all supported. NAT/PAT support is weak/absent
  — see lab 04's README for how that's handled (future plan).

## Management network

Containerlab's default `clab` Docker network, `172.20.20.0/24`. Each node in a
`topology.clab.yml` pins a **static `mgmt-ipv4`** (`.11`, `.12`, …) so every
lab's `inventory.yml` is stable. This network is host-local — not routable
from the laptop, not reachable from the LAN — so it needs **no firewall
change**; Ansible runs co-located on the mini PC.

## RAM budget

Each cEOS node gets an explicit `memory: 1024M` limit in its `topology.clab.yml`.
Run **one lab at a time** — a 4-5 node lab is 4-5 GB, tight alongside the
~0.7 GB newsfeed stack on 8 GB total. The heaviest labs (03, 05) should wait
for a RAM upgrade (one free SODIMM slot, up to 16 GB total) if things feel tight.

## GNS3 (retired)

`gns3server` is stopped and disabled (`systemctl disable --now gns3server`) —
package left installed, consumes no RAM. The old `br-gns3mgmt` bridge and its
`ufw` rules are left in place (host-only, harmless; removing them would be a
netplan change with no upside on an SSH-only host).

## Toolchain verified

_(filled in Task 12: date, Containerlab version, cEOS version/tag, smoke test
result)_
