# Lab 01: OSPF multi-area

Five FRR routers, three OSPF areas, deployed and checked entirely by Ansible.
Everything runs inside containers on one host (Containerlab's own Docker
network). It does not touch any physical network.

## Topology

```
  AREA 1            AREA 0 (backbone)               AREA 2 (totally stubby)

  r1 ---------- r2 ---------- r3 ---------- r4 ---------- r5
 LANs        ABR            ASBR           ABR          LAN
 10.1.1.1    area 1/0      static route    area 0/2     10.1.5.1
 10.1.2.1    summary       192.0.2.0/24    stub
                                          no-summary
          10.1.10.0/31 | 10.1.11.0/31 | 10.1.12.0/31 | 10.1.13.0/31
              area 1       area 0 (MD5)    area 0 (MD5)    area 2
```

| Router | Loopback | Role |
|--------|----------|------|
| r1 | 10.255.1.1 | internal, area 1. Host addresses 10.1.1.1 and 10.1.2.1 on `lo` |
| r2 | 10.255.2.2 | ABR area 1 / area 0. Summarises area 1 as `10.1.0.0/22` |
| r3 | 10.255.3.3 | backbone, ASBR. Redistributes a static `192.0.2.0/24` (LSA type 5) |
| r4 | 10.255.4.4 | ABR area 0 / area 2. `area 2 stub no-summary` |
| r5 | 10.255.5.5 | internal, area 2. Host address 10.1.5.1 on `lo` |

Links are `/31` point-to-point (`ip ospf network point-to-point`, so no DR/BDR
election). Backbone links use OSPF MD5 authentication with a lab-only key.

## What this lab demonstrates

- **Inter-area routes (type 3).** r1 sees r5's address as `N IA`.
- **Summarisation.** r3 sees `10.1.0.0/22`, not r1's two host routes.
- **External routes (type 5).** r1 and r4 see `192.0.2.0/24` as `N E2`.
- **Totally stubby area.** r5 holds only a default route from r4. It does not
  see the summary, the external route or area 1 at all.
- **Authentication.** Backbone adjacencies only form because the keys match.

## Run it

```bash
docker/frr-lab/build.sh
sudo containerlab deploy -t labs/01-ospf-multiarea/topology.clab.yml
ansible-playbook -i labs/01-ospf-multiarea/inventory.yml labs/01-ospf-multiarea/deploy.yml
ansible-playbook -i labs/01-ospf-multiarea/inventory.yml labs/01-ospf-multiarea/verify.yml
sudo containerlab destroy -t labs/01-ospf-multiarea/topology.clab.yml --cleanup
```

`deploy.yml` renders `templates/ospf.conf.j2` per router from `inventory.yml`
and pushes it with `cli_config`. `verify.yml` waits for the expected number of
`Full` neighbours, then asserts the route types above, that the hidden routes
are really hidden, that MD5 is active, and that r1 can ping r5 across all
three areas.

## Notes on FRR vs Cisco

- OSPF is enabled per interface (`ip ospf area N`), not with `network` statements.
- A loopback with extra addresses advertises each one as a `/32` host route.
- `area N stub no-summary` is Cisco's `area N stub no-summary` on the ABR.
