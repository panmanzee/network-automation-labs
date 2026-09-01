# Addressing plan

Authoritative for all labs. Each lab README recaps only the parts it uses.

| Scope | Range | Notes |
|-------|-------|-------|
| Management (out-of-band) | `10.10.10.0/24` | host bridge `br-gns3mgmt` = `.1`; devices `.11`+ |
| Lab data | `10.<lab#>.<segment>.0/24` | e.g. lab 01 users VLAN 10 = `10.1.10.0/24` |
| Loopbacks | `10.255.<id>.<id>/32` | `<id>` = device number within the lab |
| Point-to-point links | `10.<lab#>.<link#>.0/30` | `.1` = lower device id, `.2` = higher |

VLAN numbering: `10` users, `20` servers, `99` management.

Device management IPs are assigned in each lab's `inventory.yml` and its
`configs/bootstrap/<device>-boot.cfg`. The management interface never carries
lab data traffic.
