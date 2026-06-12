# OCI Storage

## Boot Volumes

| VM | Boot Vol OCID | Size | VPU/GB | Performance |
|----|---------------|------|--------|-------------|
| sin-supabase | `ocid1.bootvolume.oc1.eu-frankfurt-1.abtheljt2glshizhujgl4ncqo3a3xtqcvmhkbfs7aew7qtqct45w2nyhil7a` | 50 GB | 10 | Balanced |
| A2A-SIN-Token-Blackbox | `ocid1.bootvolume.oc1.eu-frankfurt-1.abtheljt4pxccwplmwml2de5gvwyyzyfdk7b5yo664pk32cq4gqb44enodxa` | ~47 GB | 10 | Balanced |

## Always Free Storage

- 200 GB total Block Storage per A1 VM
- 5 GB Object Storage (free)
- 10 GB Archive Storage (free)

## Currently Used

- sin-supabase: 50 GB boot + Supabase volume mounts (~30 GB data)
- A2A-SIN-Token-Blackbox: ~47 GB boot

**Total: ~127 GB of ~400 GB free A1 block storage (across 2 A1 VMs)**

## Useful commands

```bash
# Boot volume attachments
oci compute boot-volume-attachment list \
  --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia \
  --availability-domain "PjAL:EU-FRANKFURT-1-AD-1" \
  --region eu-frankfurt-1

# Block volume limits
oci limits resource-availability get \
  --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia \
  --service-name block-storage --limit-name "block-volume-count" \
  --availability-domain "PjAL:EU-FRANKFURT-1-AD-1" --region eu-frankfurt-1
```
