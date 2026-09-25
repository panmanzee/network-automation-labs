# Network Automation Labs

[![CI](https://github.com/panmanzee/network-automation-labs/actions/workflows/ci.yml/badge.svg)](https://github.com/panmanzee/network-automation-labs/actions/workflows/ci.yml)
![Containerlab](https://img.shields.io/badge/Containerlab-topology--as--code-1D63ED)
![FRRouting](https://img.shields.io/badge/FRRouting-10.7.1-1793D1)
![Ansible](https://img.shields.io/badge/Ansible-frr.frr%20%C2%B7%20netcommon-EE0000?logo=ansible&logoColor=white)
![License](https://img.shields.io/badge/license-MIT%20%2F%20CC--BY--4.0-lightgrey)

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

The repo started on GNS3 + Arista cEOS; it was re-platformed to
Containerlab + FRRouting after hitting vendor image licensing friction that a
pure open-source toolchain doesn't have — see the git history for the full
migration.

## How it works

- **Containerlab** builds each lab's topology from `topology.clab.yml` using a
  repo-built FRR image (`docker/frr-lab/`); nodes boot with a minimal
  bind-mounted `frr.conf` and are SSH-reachable immediately.
- Everything past "reachable over SSH" is **Ansible** (`frr.frr` +
  `ansible.netcommon`, `network_cli`, SSH-key auth) — `deploy.yml` pushes the
  full `frr.conf`, `verify.yml` asserts the expected state and captures the
  evidence.
- **CI** (`.github/workflows/ci.yml`) doesn't just lint YAML — the
  `deploy-smoke` job builds the FRR image, brings up a real Containerlab
  topology, runs the Ansible playbook against the live nodes, and tears down,
  so the toolchain is proven to actually converge on every push, not just
  "the files parse."
- See [`docs/automation.md`](docs/automation.md) for the full flow and the
  FRR-vs-Cisco CLI notes.

## Repo layout

```
.
├── docker/frr-lab/          # Dockerfile + build script — the FRR node image (not committed, built on demand)
├── ansible/
│   ├── roles/frr_base/      # shared role: push config, verify state
│   └── requirements.yml     # frr.frr + ansible.netcommon
├── smoke/                   # 2-node topology — the runnable-today proof of the toolchain (see below)
├── labs/                    # per-lab topology + configs + deploy/verify playbooks + write-up (planned — see below)
├── docs/
│   ├── lab-environment.md   # one-time host/Containerlab/FRR-image setup
│   ├── automation.md        # bootstrap flow, auth model, FRR-vs-Cisco notes
│   └── addressing.md        # IP plan
└── .github/workflows/ci.yml # lint + syntax-check + topology validation + live smoke deploy
```

## Labs

| # | Lab | Topics | Status |
|---|-----|--------|--------|
| 01 | OSPF multi-area | areas, LSA types, DR/BDR, key-chain auth, `area range` summarisation, stub/NSSA | planned |
| 02 | BGP fundamentals | eBGP/iBGP, route-reflector, path selection, prefix-lists + route-maps, communities, aggregation | planned |
| 03 | EVPN / VXLAN fabric | leaf-spine, eBGP-unnumbered underlay, EVPN overlay, L2VNI + L3VNI symmetric IRB | planned |

**Honest status:** the automation foundation — image, Ansible role, CI
pipeline, docs — is built and proven end-to-end by the `smoke/` topology
below; the three protocol labs themselves are designed but not yet built.
This repo currently demonstrates the *infrastructure-as-code toolchain*, not
finished OSPF/BGP/EVPN configuration work.

## Reproduce

See [`docs/lab-environment.md`](docs/lab-environment.md) for the one-time setup
(Containerlab install, FRR image build), then per lab: `sudo containerlab
deploy -t labs/<lab>/topology.clab.yml`, `ansible-playbook -i
labs/<lab>/inventory.yml labs/<lab>/deploy.yml`, `ansible-playbook -i
labs/<lab>/inventory.yml labs/<lab>/verify.yml`.

Until the first lab lands, the [`smoke/`](smoke/) topology is the
runnable-today proof of the toolchain:

```bash
docker/frr-lab/build.sh
sudo containerlab deploy -t smoke/topology.clab.yml
ansible-playbook -i smoke/inventory.yml smoke/smoke.yml
```

## License

MIT for scripts, playbooks and the Dockerfile; CC-BY-4.0 for the written lab
guides (everything under [`docs/`](docs/) and each lab's `README.md`). Full MIT
text in [`LICENSE`](LICENSE).

