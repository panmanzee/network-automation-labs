# Lab 02: BGP fundamentals

An ISP core (AS 65100) with two customers, built and checked by Ansible.
Everything runs inside containers on one host. It does not touch any physical
network.

## Topology

```
  AS 65001                 AS 65100 (ISP)                  AS 65002

  r1 ====eBGP==== r2 ---- r3 ---- r4 ====eBGP==== r5
  customer A     edge     (RR)    edge           customer B
   \_____________eBGP, second path_____/
```

r1 announces `198.51.100.0/24` and the bogus `10.99.0.0/24`. r5 announces
`203.0.113.0/25` and `203.0.113.128/25`.

| Link | Subnet | Type |
|------|--------|------|
| r1 - r2 | 10.2.10.0/31 | eBGP |
| r1 - r4 | 10.2.11.0/31 | eBGP (second path) |
| r2 - r3 | 10.2.12.0/31 | core, OSPF |
| r3 - r4 | 10.2.13.0/31 | core, OSPF |
| r4 - r5 | 10.2.14.0/31 | eBGP |

Inside AS 65100, OSPF carries the loopbacks and iBGP peers between them. r3 is
a route reflector with r2 and r4 as clients, so there is no full mesh.

## What this lab demonstrates

- **eBGP and iBGP.** Sessions to customers and between ISP routers, with
  `update-source lo` and `next-hop-self` on the edges.
- **Route reflector.** r2 learns r4's routes only through r3
  (`originatorId` and `clusterList` are present on the path).
- **Prefix filtering.** r1 announces a mistake, `10.99.0.0/24`. The
  `CUST-A` prefix-list on r2 and r4 drops it, so it never reaches r3.
- **Path selection.** r1 is dual-homed. r4 sets local-preference 200 and r2
  sets 100, so every ISP router picks r4 as the exit. On r2 the selection
  reason is `Local Pref`.
- **Communities.** Customer A routes are tagged `65100:100` at the edge.
- **Aggregation.** r5 announces two `/25`s. r4 aggregates them to
  `203.0.113.0/24 summary-only`, so r1, r2 and r3 see only the `/24`.

## Run it

```bash
docker/frr-lab/build.sh
sudo containerlab deploy -t labs/02-bgp-fundamentals/topology.clab.yml
ansible-playbook -i labs/02-bgp-fundamentals/inventory.yml labs/02-bgp-fundamentals/deploy.yml
ansible-playbook -i labs/02-bgp-fundamentals/inventory.yml labs/02-bgp-fundamentals/verify.yml
sudo containerlab destroy -t labs/02-bgp-fundamentals/topology.clab.yml --cleanup
```

`deploy.yml` renders `templates/bgp.conf.j2` per router from `inventory.yml`.
`verify.yml` waits for all sessions to be `Established`, then reads
`show ip bgp <prefix> json` and asserts the best path, local-preference,
community and AS path, plus the prefixes that must be absent.

## Notes on FRR vs Cisco

- FRR refuses eBGP routes with no policy by default (`bgp ebgp-requires-policy`).
  The lab turns this off globally and applies inbound route-maps where the
  filtering matters.
- Customers advertise with `network` plus a static blackhole route, which gives
  BGP something to originate without real hosts.
