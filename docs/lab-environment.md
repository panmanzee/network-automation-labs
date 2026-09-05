# Lab environment

Host: a headless Ubuntu Server mini-PC (Intel i5-4570T, 8 GB RAM), administered
over SSH only — no console/IPMI. It sits on a DHCP-reserved LAN address. Docker
is already installed and shared with other services on the box.

Containerlab reuses the same Docker daemon; labs get their own isolated network
and don't touch the other containers. The lab user is in the `docker` group, so
`docker` needs no `sudo`; `containerlab deploy/destroy` still does (it
manipulates network namespaces).

## Containerlab

- Installed with `bash -c "$(curl -sL https://get.containerlab.dev)"`.
- Version: `0.79.0` (at time of writing).
- Every `deploy`/`destroy` is run with `sudo` from the repo root, e.g.:
  `sudo containerlab deploy -t smoke/topology.clab.yml`.

## FRR node image

Network nodes are Containerlab `kind: linux` running a small image built from
`docker/frr-lab/Dockerfile`: `quay.io/frrouting/frr:<version>` plus
`openssh` and an `automation` user whose login shell is `vtysh`, so the node
behaves like an SSH-managed router. **No image is committed** — it is built
locally / in CI with the helper script:

```bash
docker/frr-lab/build.sh            # tags frr-lab:local, FRR 10.7.1
docker/frr-lab/build.sh 10.8.0     # or a specific FRR tag
```

The script builds from a throwaway context so the SSH public key it bakes into
`authorized_keys` (`ansible/.ssh/id_ed25519.pub`) is never copied next to the
Dockerfile — don't `docker build docker/frr-lab/` directly, it has no pubkey in
context and fails.

- FRR base version: pinned via the Dockerfile `ARG FRR_VERSION` (default
  `10.7.1`); override with `--build-arg FRR_VERSION=<tag>` for a different
  `quay.io/frrouting/frr` tag.
- Version in use: `10.7.1` (newest stable `10.x` on quay.io as of 2026-09-05;
  `10.3` from the original plan no longer has a published tag).
- FRR's `vtysh` CLI is Cisco-IOS-like for routing; per-lab READMEs note the
  deltas (`service integrated-vtysh-config` instead of `copy run start`, BGP
  unnumbered idiom, no `enable secret` layer, some `show` differences).

## Management network

Containerlab's default `clab` Docker network, `172.20.20.0/24`. Each node in a
`topology.clab.yml` pins a static `mgmt-ipv4` (`.11`, `.12`, …) so every lab's
`inventory.yml` is stable. Host-local — not routable from the laptop or LAN —
so it needs no firewall change; Ansible runs co-located on the mini PC.

## RAM budget

Not a constraint. An FRR container idles at ~40–90 MB. `memory: 256M` per node
is a generous cap; a 6-node lab is well under 1 GB, so labs can even run
concurrently alongside the ~0.7 GB newsfeed stack.

## GNS3 (retired)

`gns3server` should be stopped and disabled (`sudo systemctl disable --now
gns3server`) — package left installed, consumes no RAM. The old `br-gns3mgmt`
bridge and its `ufw` rules are left in place (host-only, harmless; removing
them would be a netplan change with no upside on an SSH-only host).

## Toolchain verified

- **2026-09-05**: CI `deploy-smoke` — `containerlab deploy -t
  smoke/topology.clab.yml` → `ansible-playbook smoke/smoke.yml` → `frr1 OK` /
  `frr2 OK` → `containerlab destroy --cleanup`. FRR version `10.7.1`,
  Containerlab `0.79.0`, driven over `ansible.netcommon.network_cli` +
  `frr.frr.frr` into `vtysh`. Toolchain proven end-to-end in GitHub Actions.
