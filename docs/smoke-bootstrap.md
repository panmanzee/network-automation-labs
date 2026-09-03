# Throwaway topology bootstrap (Foundation Task 11)

Project `_smoke` in the GNS3 GUI: **R1**, **R2** (c7200 template) + a **Cloud**
node bound to `br-gns3mgmt`. Link `R1 Fa0/0 — Cloud` and `R2 Fa0/0 — Cloud`.

On a default c7200 the mgmt port is `FastEthernet0/0`. If your template uses a
GigabitEthernet I/O controller, replace `FastEthernet0/0` with `GigabitEthernet0/0`.

The device password below (`ChangeMe_Dev_Pw1`) must match `vault_device_password`
in `ansible/vault.yml`. Pick your own and keep them identical.

## R1 — paste at the console

```
enable
configure terminal
hostname R1
ip domain name lab.local
no ip domain lookup
username automation privilege 15 secret ChangeMe_Dev_Pw1
enable secret ChangeMe_Dev_Pw1
crypto key generate rsa modulus 2048
ip ssh version 2
interface FastEthernet0/0
 ip address 10.10.10.11 255.255.255.0
 no shutdown
 exit
line vty 0 4
 login local
 transport input ssh
 exec-timeout 30 0
 exit
end
write memory
```

## R2 — paste at the console

```
enable
configure terminal
hostname R2
ip domain name lab.local
no ip domain lookup
username automation privilege 15 secret ChangeMe_Dev_Pw1
enable secret ChangeMe_Dev_Pw1
crypto key generate rsa modulus 2048
ip ssh version 2
interface FastEthernet0/0
 ip address 10.10.10.12 255.255.255.0
 no shutdown
 exit
line vty 0 4
 login local
 transport input ssh
 exec-timeout 30 0
 exit
end
write memory
```

## Verify from the mini PC

```bash
ping -c2 10.10.10.11
ping -c2 10.10.10.12
ssh -o StrictHostKeyChecking=no automation@10.10.10.11 'show version | include IOS'
```

Then run the Ansible smoke test from the repo root:

```bash
cd ~/ccna-gns3-labs
ansible-playbook -i ansible/inventory-smoke.yml ansible/smoke.yml
```

Expected: `ok=2`, `R1 OK` / `R2 OK`, `failed=0`.

## Optional: prove SSH public-key auth

Console into R1:

```
configure terminal
ip ssh pubkey-chain
 username automation
  key-string
```

Paste the contents of `ansible/.ssh/id_ed25519.pub` (wrap if IOS complains), then:

```
  exit
 exit
exit
write memory
```

Temporarily comment the `ansible_password` line in `ansible/inventory-smoke.yml`
and re-run `ansible-playbook -i ansible/inventory-smoke.yml -l R1 ansible/smoke.yml`
— it should succeed with no password prompt (key from `ansible.cfg`
`private_key_file`). Restore the line afterward. If IOS 12.x/15.x on your c7200
rejects `pubkey-chain`, note it in `lab-environment.md` and stay on the vault
password — that is the documented fallback.
