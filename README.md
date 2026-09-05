# Network Automation Labs

Hands-on **L3 network-automation** labs built with **Containerlab** and
**FRRouting**, each documented as a solved scenario: topology file, topology
diagram, full device configs, Ansible deploy + verify, captured verification
output, and a short write-up. Everything is text and lives in git — no GUI, no
click-through screenshots, and every component is free and open-source with no
vendor login of any kind.

FRR's `vtysh` CLI is deliberately Cisco-IOS-like (`router ospf`, `network …
area 0`, `show ip route`, `show ip ospf neighbor`), so the routing concepts
transfer directly to Cisco / Arista / Juniper. Each lab README notes where FRR
syntax differs.

Design: [`docs/`](docs/) · Environment setup: [`docs/lab-environment.md`](docs/lab-environment.md) · How the automation works: [`docs/automation.md`](docs/automation.md)

## Why FRRouting + Containerlab

FRR is a production-grade routing stack (it's the engine inside SONiC and
Cumulus Linux) with a real SSH-managed CLI, published as a small public
container image — no account, no license file, no VM. Containerlab wires the
topology and Ansible drives the config, so the whole repo is
infrastructure-as-code rather than GUI screenshots. FRR is a **router**, not a
switch, so this repo is focused on L3: IGP design, BGP policy, and data-center
EVPN/VXLAN.

## Labs

| # | Lab | Topics | Status |
|---|-----|--------|--------|
| 01 | OSPF multi-area | areas, LSA types, DR/BDR, key-chain auth, `area range` summarisation, stub/NSSA | planned |
| 02 | BGP fundamentals | eBGP/iBGP, route-reflector, path selection, prefix-lists + route-maps, communities, aggregation | planned |
| 03 | EVPN / VXLAN fabric | leaf-spine, eBGP-unnumbered underlay, EVPN overlay, L2VNI + L3VNI symmetric IRB | planned |

## Skills matrix

_Filled in as labs are completed — maps each lab to common network-automation
and data-center network engineering job requirements._

## How it works

- **Containerlab** builds each lab's topology from `topology.clab.yml` using a
  repo-built FRR image (`docker/frr-lab/`); nodes boot with a minimal
  bind-mounted `frr.conf` and are SSH-reachable immediately.
- Everything past "reachable over SSH" is **Ansible** (`frr.frr` +
  `ansible.netcommon`, `network_cli`, SSH-key auth) — `deploy.yml` pushes the
  full `frr.conf`, `verify.yml` asserts the expected state and captures the
  evidence.
- See [`docs/automation.md`](docs/automation.md) for the full flow and the
  FRR-vs-Cisco CLI notes.

## Reproduce

See [`docs/lab-environment.md`](docs/lab-environment.md) for the one-time setup
(Containerlab install, FRR image build), then per lab: `sudo containerlab
deploy -t labs/<lab>/topology.clab.yml`, `ansible-playbook -i
labs/<lab>/inventory.yml labs/<lab>/deploy.yml`, `ansible-playbook -i
labs/<lab>/inventory.yml labs/<lab>/verify.yml`.

Until the first lab lands, the [`smoke/`](smoke/) topology is the
runnable-today proof of the toolchain: `docker/frr-lab/build.sh && sudo
containerlab deploy -t smoke/topology.clab.yml && ansible-playbook -i
smoke/inventory.yml smoke/smoke.yml`.

## License

MIT for scripts, playbooks and the Dockerfile; CC-BY-4.0 for the written lab
guides (everything under [`docs/`](docs/) and each lab's `README.md`). Full MIT
text in [`LICENSE`](LICENSE).
