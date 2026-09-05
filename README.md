# Network Automation Labs

Hands-on network-automation labs built with **Containerlab** and **Arista
cEOS**, each documented as a solved scenario: topology file, topology diagram,
full device configs, Ansible deploy + verify, captured verification output,
and a short write-up. Everything is text and lives in git — no GUI, no
click-through screenshots.

Every lab also maps to the **CCNA 200-301** exam blueprint (see the skills
matrix below) — Arista EOS's CLI overlaps roughly 85% with Cisco IOS for these
topics; each lab README calls out the handful of deltas (e.g. **VRRP** instead
of the Cisco-proprietary **HSRP**).

Design: [`docs/`](docs/) · Environment setup: [`docs/lab-environment.md`](docs/lab-environment.md) · How the automation works: [`docs/automation.md`](docs/automation.md)

## Why Containerlab + Arista, not GNS3 + Cisco IOS

Cisco IOS/IOL images are licensed software, not freely redistributable —
there's no legal way to source them without a paid Cisco contract or owned
hardware. Arista publishes a free cEOS-lab container image for personal/study
use, has a real SSH-managed CLI (not a simulator), and pairs naturally with
Containerlab + Ansible — a stronger signal for a network-automation portfolio
than a GNS3 screenshot.

## Labs

| # | Lab | Topics | Status |
|---|-----|--------|--------|
| 01 | Campus L2 | VLANs, 802.1Q trunking, RSTP root tuning, LACP, LLDP | planned |
| 02 | Inter-VLAN + FHRP | SVIs, DHCP relay, VRRP failover | planned |
| 03 | OSPF multi-area | areas, DR/BDR, MD5 auth, ABR summarisation | planned |
| 04 | Edge routing & security | static/default routing, ACLs, SSH/AAA hardening | planned |
| 05 | Operations | NTP, Syslog, SNMPv2c/v3, config sessions | planned |

## Skills matrix

_Filled in as labs are completed — maps each lab to CCNA 200-301 exam topics._

## How it works

- **Containerlab** drives Docker directly to build each lab's topology from
  `topology.clab.yml`; Arista cEOS containers boot with a minimal
  `startup-config` that makes them SSH-reachable immediately.
- Everything past "reachable over SSH" is **Ansible** (`arista.eos` collection,
  `network_cli`, SSH-key auth) — `deploy.yml` pushes the full config,
  `verify.yml` asserts the expected state and captures the evidence.
- See [`docs/automation.md`](docs/automation.md) for the full flow and the
  Arista/Cisco CLI deltas.

## Reproduce

See [`docs/lab-environment.md`](docs/lab-environment.md) for the one-time setup
(Containerlab install, cEOS import), then per lab: `sudo containerlab deploy
-t labs/<lab>/topology.clab.yml`, `ansible-playbook -i labs/<lab>/inventory.yml
labs/<lab>/deploy.yml`, `ansible-playbook -i labs/<lab>/inventory.yml
labs/<lab>/verify.yml`.

## License

MIT for scripts and playbooks; CC-BY-4.0 for the written lab guides.
