# OCI SSH Keys

## Local SSH Key Inventory

| Key File | Public Fingerprint | Purpose | User | VM |
|----------|--------------------|---------|------|-----|
| `~/.ssh/id_ed25519` | `AAAAC3NzaC1lZDI1NTE5AAAAIEVBMJZHCzIS1NifTPbjNZuEfTse2OGXD/NxXHO1Xl1F` | **PRIMARY** | ubuntu | sin-supabase (92.5.60.87) |
| `~/.ssh/oci-vm3` | ed25519 | Legacy | ubuntu/opc/root | (old VMs) |
| `~/.ssh/host_ed25519_key` | n/a | Mac host SSH | local | n/a |
| `~/.ssh/host_rsa_key` | n/a | Mac host SSH | local | n/a |
| `~/.ssh/id_ed25519` (uuid 387b1c08) | (old) | (deprecated) | — | — |
| `~/.ssh/aura-call-vm-key` | (unknown) | Aura Call VM | unknown | (legacy) |
| `~/.ssh/lightning_rsa` | (unknown) | Lightning (BTC/LN) | unknown | (legacy) |
| `~/.ssh/zoe_vm_key` | (unknown) | Zoe VM | unknown | (legacy) |

## Authorized VM SSH keys

The OCI metadata service stores the authorized key for each VM:

```bash
# Get a VM's authorized SSH key
oci compute instance list \
  --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia \
  --region eu-frankfurt-1 \
  --query "data[?\"display-name\"=='sin-supabase'].\"metadata\".\"ssh_authorized_keys\"" \
  --output json
```

## SSH Access

```bash
# Primary access
ssh -i ~/.ssh/id_ed25519 ubuntu@92.5.60.87

# With command
ssh -i ~/.ssh/id_ed25519 ubuntu@92.5.60.87 "docker ps | head -10"

# SCP file
scp -i ~/.ssh/id_ed25519 ./local-file.txt ubuntu@92.5.60.87:/home/ubuntu/

# Reverse SSH tunnel (for VMs without public IP)
ssh -i ~/.ssh/id_ed25519 -R 8080:localhost:80 ubuntu@92.5.60.87
```

## Key Rotation

```bash
# Generate new key
ssh-keygen -t ed25519 -f ~/.ssh/oci-frankfurt-2026 -C "ops@sin-supabase"

# Add to VM
ssh-copy-id -i ~/.ssh/oci-frankfurt-2026.pub ubuntu@92.5.60.87

# Test
ssh -i ~/.ssh/oci-frankfurt-2026 ubuntu@92.5.60.87

# Update OCI metadata (re-applies at next reboot)
oci compute instance update \
  --instance-id <ocid> \
  --metadata "{\"ssh_authorized_keys\": \"$(cat ~/.ssh/oci-frankfurt-2026.pub)\"}"
```
