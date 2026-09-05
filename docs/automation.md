# Automation layer

## Bootstrap (the chicken-and-egg problem)

Containerlab bind-mounts each node's `configs/bootstrap/<node>.conf` as
`/etc/frr/frr.conf` (and, if present, `configs/daemons/<node>` as
`/etc/frr/daemons`). The `frr-lab` image already contains `sshd` and the
`automation` user (SSH-key auth from `ansible/.ssh/id_ed25519.pub`, `vtysh`
login shell). So the node is reachable over SSH — and answers on `vtysh` — the
moment it boots. The bootstrap config carries only hostname,
`service integrated-vtysh-config`, and interface/loopback IPs; every protocol
line is pushed afterward by Ansible. Both configs are version-controlled, so
reachability and end state are reproducible.

## Per-lab flow

1. `sudo containerlab deploy -t topology.clab.yml` — nodes boot the bootstrap
   config, mgmt IPs come up.
2. `ansible-playbook -i inventory.yml deploy.yml` — pushes the full
   `configs/<node>.conf` via `ansible.netcommon.cli_config`.
3. Hands-on learning at `vtysh` (`docker exec -it clab-<lab>-<node> vtysh`) —
   the point of the lab.
4. `ansible-playbook -i inventory.yml verify.yml` — runs
   `ansible.netcommon.cli_command`, asserts the expected state, writes
   `output/*.txt`.
5. `scripts/pull-configs.sh` — `show running-config` back into
   `configs/<node>.conf` so committed config matches the live device.
6. `sudo containerlab destroy -t topology.clab.yml` — tear down, commit.

## Auth model

**SSH public key only.** The `frr-lab` image bakes
`ansible/.ssh/id_ed25519.pub` into `automation`'s `authorized_keys` and sets
`vtysh` as its login shell. FRR nodes have no password and no enable secret in
these labs, so there is no Ansible Vault and no `become` layer — the inventory
connection block is just `network_cli` + `frr.frr.frr` + `ansible_user:
automation`.

## FRR vtysh vs Cisco IOS — notes that show up in this repo

- `service integrated-vtysh-config` writes one `/etc/frr/frr.conf`; there is no
  `copy run start` / `write memory` split.
- `do show …` works inside config mode, same as IOS.
- BGP unnumbered (peer on an interface, IPv6 link-local next-hop) is the
  FRR/Cumulus idiom used in lab 03 — no Cisco equivalent syntax.
- No `enable secret` / privilege-level layer in these labs.
- `show ip route`, `show ip ospf neighbor`, `show bgp summary` read almost
  identically to IOS; route-maps and prefix-lists are near-identical.

## What CI proves

Because the FRR image is public and small, CI does more than parse files:

- `yamllint`, `ansible-lint`, `ansible-playbook --syntax-check` on every
  playbook (well-formed).
- `containerlab` schema/parse check of every `topology.clab.yml`.
- **`deploy-smoke`**: builds the `frr-lab` image, `containerlab deploy`s
  the throwaway `smoke/` topology, runs `ansible-playbook smoke/smoke.yml`
  against the live nodes, and tears down — the toolchain actually converges in
  CI, not just "the YAML is valid".

Per-lab deploy-in-CI (running each real lab's `deploy.yml`/`verify.yml` against
a live topology in Actions) is a Phase-2 item; for now each lab's
`output/verification.md`, captured locally, is its evidence.
