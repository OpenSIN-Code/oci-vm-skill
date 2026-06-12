---
name: oci-vm
description: OCI VM inventory, access, and management — Frankfurt Always Free Tier inventory + SSH access for sin-supabase and other VMs. Triggers on "list OCI VMs", "check OCI capacity", "OCI free tier", "oci-vm", "sin-supabase", "92.5.60.87", "vm.Standard.A1".
version: 1.0.0
author: Jeremy Schulze
license: MIT
---

# OCI VM Skill

This skill provides instant access to the OpenSIN OCI infrastructure in eu-frankfurt-1.

## When to use

- "List all OCI VMs" / "Welche VMs laufen?"
- "Check free capacity" / "Wie viel ist noch frei?"
- "SSH into sin-supabase" / "Verbinde mit OCI VM"
- "Add new A1 VM" / "Always Free Tier ausnutzen"
- "Check VM health" / "VM Status"
- References to `92.5.60.87`, `sin-supabase`, `VM.Standard.A1.Flex`, `VM.Standard.E2.1.Micro`

## When NOT to use

- Other cloud providers (AWS, Azure, GCP) — use their dedicated skills
- Local Docker / OrbStack — use `use-orbstack` skill
- Kubernetes deployments — use `k8s` skill if available

## Quick reference

### Inventory command (always works)

```bash
oci compute instance list \
  --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia \
  --region eu-frankfurt-1 \
  --query "data[*].{Name:\"display-name\",State:\"lifecycle-state\",Shape:\"shape\",OCPU:\"shape-config\".\"ocpus\",MemoryGB:\"shape-config\".\"memory-in-gbs\",Created:\"time-created\"}" \
  --output table
```

### Capacity check (Always Free Tier)

```bash
# A1 cores in AD-1
oci limits resource-availability get \
  --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia \
  --service-name compute --limit-name "standard-a1-core-count" \
  --availability-domain "PjAL:EU-FRANKFURT-1-AD-1" --region eu-frankfurt-1

# A1 memory
oci limits resource-availability get \
  --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia \
  --service-name compute --limit-name "standard-a1-memory-count" \
  --availability-domain "PjAL:EU-FRANKFURT-1-AD-1" --region eu-frankfurt-1

# E2.1.Micro count
oci limits resource-availability get \
  --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia \
  --service-name compute --limit-name "vm-standard-e2-1-micro-count" \
  --availability-domain "PjAL:EU-FRANKFURT-1-AD-1" --region eu-frankfurt-1
```

### SSH access

```bash
# sin-supabase (primary, used 99% of the time)
ssh -i ~/.ssh/id_ed25519 ubuntu@92.5.60.87

# Alternative key (older VM)
ssh -i ~/.ssh/oci-vm3 ubuntu@92.5.60.87  # only for legacy VMs
```

### Always Free limits summary (Frankfurt AD-1)

| Resource | Limit | Used | Free |
|----------|-------|------|------|
| A1.OCPU | 250 | 4 (sin-supabase) | **246** |
| A1.Memory (GB) | 1666 | 24 | **1642** |
| A1.Boot Vol (GB) | 200 | 50 | **~150** |
| E2.1.Micro count | 2 | 1 (A2A-SIN-Token-Blackbox) | **1** |
| Block Volumes | 100 | 0 | **100** |
| VCN | unlimited | 1 (sin-supabase-vcn) | — |
| Public IPs | unlimited | 2 (ephemeral) | — |

### Other ADs (completely free)

- AD-2: 250 OCPU / 1666 GB Memory
- AD-3: 250 OCPU / 1666 GB Memory

**Total free across all ADs: 746 OCPU, 4974 GB Memory**

## Inventory output (current state)

```
+------------------------+------------------------+------+--------+----------+
| Name                   | Shape                  | OCPU | Memory | State    |
+------------------------+------------------------+------+--------+----------+
| sin-supabase           | VM.Standard.A1.Flex    | 4    | 24 GB  | RUNNING  |
| A2A-SIN-Token-Blackbox | VM.Standard.E2.1.Micro | 1    | 1 GB   | RUNNING  |
+------------------------+------------------------+------+--------+----------+
```

## VCN + Network

- VCN: `sin-supabase-vcn` (10.16.0.0/16, DNS label `sinsup`)
- Subnet: `sin-supabase-public-subnet` (10.16.0.0/24, `publicsub`)
- Public IPs: 92.5.60.87 (sin-supabase), 92.5.116.158 (legacy)

## SSH Keys map

| Key File | Purpose | User |
|----------|---------|------|
| `~/.ssh/id_ed25519` | **PRIMARY** — sin-supabase access | ubuntu |
| `~/.ssh/oci-vm3` | Legacy, old VM access | ubuntu / opc / root |
| `~/.ssh/host_ed25519_key` | Local Mac SSH host key | n/a |

## Common commands

```bash
# Health check all VMs
scripts/health-check.sh

# Inventory
scripts/inventory.sh

# Capacity
scripts/capacity.sh

# SSH helper
scripts/ssh-helper.sh sin-supabase
```

## Security notes

- OCI API keys are in `~/.oci/`
- SSH private keys are in `~/.ssh/`
- Never commit either directory to git
- Use `--scope-type` for tenant-wide queries

## References

- [tenancy.md](references/tenancy.md) — OCI IAM + compartments
- [networking.md](references/networking.md) — VCN / subnets / IPs
- [storage.md](references/storage.md) — Block / boot volumes
- [ssh-keys.md](references/ssh-keys.md) — SSH key inventory
