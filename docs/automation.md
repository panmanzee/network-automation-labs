# Automation layer

## Bootstrap (the chicken-and-egg problem)

Containerlab injects each node's `configs/startup/<node>.cfg` as its
startup-config the moment it boots: hostname, the `automation` user with an
SSH public key (from `ansible/.ssh/id_ed25519.pub`), `ip routing`, and the
eAPI (`management api http-commands`) turned on — Containerlab's own
readiness check for the `ceos` kind polls eAPI to know a node has finished
booting. That's the whole job of the startup-config: get the node reachable
over SSH. Everything else is Ansible.

## Per-lab flow

1. `sudo containerlab deploy -t topology.clab.yml` — nodes boot, startup-config
   applies, mgmt IPs come up.
2. `ansible-playbook -i inventory.yml deploy.yml` — pushes the full
   `configs/<node>.cfg` via `arista.eos.eos_config`.
3. Hands-on learning at the EOS CLI (`docker exec -it <node> Cli`) — this is
   the point of the lab.
4. `ansible-playbook -i inventory.yml verify.yml` — runs `arista.eos.eos_command`
   and asserts the expected state, writing `output/*.txt`.
5. `scripts/pull-configs.sh` — pulls `show running-config` back into
   `configs/<node>.cfg` so committed config matches the live device.
6. `sudo containerlab destroy -t topology.clab.yml` — tear down, commit.

## Auth model

**SSH public key is primary** — the same key (`ansible/.ssh/id_ed25519`) is
baked into every node's startup-config via `username automation ssh-key
<pubkey>`. The Ansible-Vault-encrypted `vault_device_password`
(`ansible/vault.yml`) is the fallback and the `enable`/local-auth password
used once a lab's `deploy.yml` sets the device's real `secret` — it is
**never** placed in plaintext in a startup-config or any other committed
file. The throwaway `smoke/` topology (proving the toolchain, not a real lab)
skips the vault password entirely and authenticates purely by SSH key.

## Arista EOS vs Cisco IOS — CLI deltas that show up in this repo

- FHRP: **VRRP**, not HSRP (Cisco-proprietary, unsupported on EOS). VRRP is
  also on the CCNA 200-301 blueprint.
- `enable`/local-user password model: EOS's `secret 0|5|7 <password>` mirrors
  IOS's `secret`, but the become plugin is `arista.eos.enable`
  (not `cisco.ios.enable`).
- `spanning-tree mode mstp` is EOS's default (IOS defaults to PVST+).
- NAT/PAT on the device itself is weak/absent on cEOS — lab 04 shows the
  concept on a Linux CPE (`iptables MASQUERADE`) instead; exam-CLI NAT is
  drilled separately in Packet Tracer.
- `show` commands, ACL syntax (`ip access-group`), and OSPF config are close
  to identical between the two CLIs.

## What CI can and can't prove

GitHub Actions has no cEOS image and can't run Containerlab deploys. CI
proves the automation is **well-formed**: `yamllint`, `ansible-lint`, a
parse/schema check of every `topology.clab.yml`, and
`ansible-playbook --syntax-check` on every playbook. It cannot prove a lab
actually reaches its target state — that's proven locally, once, when the
lab is built, and the captured `output/verification.md` is the evidence.
