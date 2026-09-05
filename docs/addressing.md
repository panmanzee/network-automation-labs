# Addressing plan

Authoritative for all labs. Each lab README recaps only the parts it uses.

| Scope | Range | Notes |
|-------|-------|-------|
| Management (out-of-band) | `172.20.20.0/24` | Containerlab's `clab` network; nodes get a static `mgmt-ipv4` (`.11`+) per `topology.clab.yml` |
| Lab data | `10.<lab#>.<segment>.0/24` | e.g. lab 01 users VLAN 10 = `10.1.10.0/24` |
| Loopbacks | `10.255.<id>.<id>/32` | `<id>` = device number within the lab |
| Point-to-point links | `10.<lab#>.<link#>.0/30` | `.1` = lower device id, `.2` = higher |

VLAN numbering: `10` users, `20` servers, `99` management.

Device management IPs are assigned in each lab's `topology.clab.yml`
(`mgmt-ipv4`) and recapped in its `inventory.yml`. The management interface
never carries lab data traffic.
