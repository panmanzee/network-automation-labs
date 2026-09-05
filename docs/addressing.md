# Addressing plan

Authoritative for all labs. Each lab README recaps only the parts it uses.

| Scope | Range | Notes |
|-------|-------|-------|
| Management (out-of-band) | `172.20.20.0/24` | Containerlab's `clab` network; nodes get a static `mgmt-ipv4` (`.11`+) per `topology.clab.yml` |
| Lab data | `10.<lab#>.<segment>.0/24` | e.g. lab 01 area-1 LAN = `10.1.1.0/24` |
| Loopbacks | `10.255.<id>.<id>/32` | `<id>` = device number within the lab; also the OSPF/BGP router-id |
| Point-to-point links | `10.<lab#>.<link#>.0/31` | `/31` per RFC 3021 — a deliberate modern-practice choice |

Lab 03 (EVPN/VXLAN) uses **eBGP unnumbered** on the underlay — IPv6 link-local
next-hops, no p2p IPv4 addressing at all. VXLAN VNIs and their L3VNI are
defined in that lab's README.

Device management IPs are assigned in each lab's `topology.clab.yml`
(`mgmt-ipv4`) and recapped in its `inventory.yml`. The management interface
never carries lab data traffic.
