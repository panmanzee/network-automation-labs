# Addressing plan

Authoritative for all labs. Each lab README recaps only the parts it uses.

| Scope | Range | Notes |
|-------|-------|-------|
| Management (out-of-band) | `172.30.30.0/24` | Containerlab `clab-mgmt` network (172.20.x is already used by another Docker network on the host); nodes get a static `mgmt-ipv4` (`.11`+) per `topology.clab.yml` |
| Lab data | `10.<lab#>.<segment>.0/24` | e.g. lab 01 area-1 LAN = `10.1.1.0/24` |
| Loopbacks | `10.255.<id>.<id>/32` | `<id>` = device number within the lab; also the OSPF/BGP router-id |
| Point-to-point links | `10.<lab#>.<link#>.0/31` | `/31` per RFC 3021 — a deliberate modern-practice choice |

Lab-specific plans:

| Lab | Management | Point-to-point | Loopbacks |
|-----|-----------|----------------|-----------|
| smoke | `172.30.30.11-12` | `10.0.0.0/31` | `10.255.11.11` |
| 01 OSPF | `172.30.30.21-25` | `10.1.10-13.0/31`, LAN hosts `10.1.1.1`, `10.1.2.1`, `10.1.5.1` | `10.255.<id>.<id>` |
| 02 BGP | `172.30.30.31-35` | `10.2.10-14.0/31` | `10.255.<id>.<id>` |

Only one lab runs at a time (they share the `clab-mgmt` network).

Lab 03 (EVPN/VXLAN) uses **eBGP unnumbered** on the underlay — IPv6 link-local
next-hops, no p2p IPv4 addressing at all. VXLAN VNIs and their L3VNI are
defined in that lab's README.

Device management IPs are assigned in each lab's `topology.clab.yml`
(`mgmt-ipv4`) and recapped in its `inventory.yml`. The management interface
never carries lab data traffic.
