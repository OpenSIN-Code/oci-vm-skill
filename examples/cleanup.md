# Cleanup unused OCI resources

## Goal

Free up Always Free Tier quota by terminating unused VMs, detaching volumes, and releasing public IPs.

## Pre-flight checklist

```bash
# 1. List all VMs and their state
scripts/inventory.sh

# 2. Check if VM is really unused
ssh -i ~/.ssh/id_ed25519 ubuntu@<ip> "uptime; who; docker ps 2>/dev/null | head -10"

# 3. Make a backup of important data
ssh ubuntu@<ip> "sudo tar -czf /tmp/backup-$(date +%Y%m%d).tar.gz /opt/important-data"
scp ubuntu@<ip>:/tmp/backup-*.tar.gz ~/backups/
```

## Steps

### 1. Terminate a VM

```bash
oci compute instance terminate \
  --instance-id <vm-ocid> \
  --force
```

⚠️  The boot volume is **NOT** deleted automatically. Delete it manually.

### 2. Find and delete the boot volume

```bash
# Find the boot volume ID
oci compute boot-volume list \
  --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia \
  --availability-domain "PjAL:EU-FRANKFURT-1-AD-1" \
  --query "data[?\"display-name\"=='my-old-vm'].id" --raw-output

# Delete it
oci bv volume delete --volume-id <boot-vol-ocid> --force
```

### 3. Release ephemeral public IPs

Ephemeral IPs are released automatically when the VNIC is deleted (via VM termination). Reserved IPs:

```bash
# List reserved
oci network public-ip list \
  --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia \
  --scope REGION \
  --query "data[?lifetime=='RESERVED']"

# Delete reserved
oci network public-ip delete --public-ip-id <reserved-ip-ocid> --force
```

### 4. Verify free capacity restored

```bash
scripts/capacity.sh
```

## Cost impact

Terminating an A1 VM frees:
- 4 OCPU
- 24 GB RAM
- 50+ GB Block Storage
- 1 Public IP

All free again for new Always Free workloads.
