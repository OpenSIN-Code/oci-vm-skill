# OCI VM Skill

> Oracle Cloud Infrastructure (OCI) VM inventory, access, and management skill for opencode agents.

## What this skill provides

- **Inventory**: List all OCI VMs in your tenancy (Frankfurt Always Free Tier)
- **Capacity check**: Free tier limits (A1.OCPU, E2.Micro, Memory, Volumes, IPs)
- **SSH access**: Pre-configured SSH keys to all VMs
- **State checks**: Up/down status, region, AD placement
- **Limits queries**: Always Free eligibility per availability domain
- **Billing sanity**: No-cost verification

## Quick start

```bash
# List all running VMs
oci compute instance list --compartment-id "$OCI_TENANCY" --region eu-frankfurt-1 \
  --query "data[*].{Name:\"display-name\",State:\"lifecycle-state\",Shape:\"shape\",OCPU:\"shape-config\".\"ocpus\",MemoryGB:\"shape-config\".\"memory-in-gbs\"}" --output table

# Check free capacity for A1 cores
oci limits resource-availability get --compartment-id "$OCI_TENANCY" \
  --service-name compute --limit-name "standard-a1-core-count" \
  --availability-domain "PjAL:EU-FRANKFURT-1-AD-1" --region eu-frankfurt-1

# SSH into a VM
ssh -i ~/.ssh/id_ed25519 ubuntu@92.5.60.87
```

## Current OCI inventory (Frankfurt)

### VMs

| Name | Shape | OCPU | RAM | Public IP | SSH | Use |
|------|-------|------|-----|-----------|-----|-----|
| sin-supabase | VM.Standard.A1.Flex | 4 | 24 GB | 92.5.60.87 | `~/.ssh/id_ed25519` | Supabase (Postgres + Auth + Storage + Realtime + Kong) |
| A2A-SIN-Token-Blackbox | VM.Standard.E2.1.Micro | 1 | 1 GB | n/a | tbd | A2A Token API |

### Free Tier Status (eu-frankfurt-1, AD-1)

- A1.OCPU: 246/250 free (4 used)
- A1.Memory: 1642/1666 GB free (24 GB used)
- A1.Disk: ~199/200 GB free
- E2.1.Micro: 1/2 free (1 used)
- Block-Vol: 100/100 free
- VCN/Public-IP: unlimited

### Other ADs (fully free)

- AD-2: 250 OCPU / 1666 GB
- AD-3: 250 OCPU / 1666 GB

## OCI CLI config

The skill uses the existing OCI CLI config at `~/.oci/config`:

```ini
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaageunwvewwzuhfr6d7u2r224efrc6auzljmuqjum4ds2oheb73tva
fingerprint=c2:68:54:f5:4c:85:0f:07:29:47:54:31:00:4b:98:e5
tenancy=ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia
region=eu-frankfurt-1
key_file=/Users/jeremy/.oci/oci_api_key.pem
```

## File structure

```
oci-vm-skill/
├── README.md              # this file
├── SKILL.md               # skill manifest
├── scripts/
│   ├── inventory.sh       # one-liner: all VM status
│   ├── capacity.sh        # free tier limits per AD
│   ├── ssh-helper.sh      # SSH wrapper
│   └── health-check.sh    # all VMs reachable?
├── references/
│   ├── tenancy.md         # OCI tenancy + IAM details
│   ├── networking.md      # VCN/subnet/Public-IP
│   ├── storage.md         # Block volumes + Boot volumes
│   └── ssh-keys.md        # SSH key map
└── examples/
    ├── add-vm.md          # provision a new A1 VM
    └── cleanup.md         # delete old VMs
```

## See also

- [Sin-Supabase VM Inventory](./references/tenancy.md)
- [Always Free Tier documentation](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier.htm)
- [OCI CLI reference](https://docs.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
