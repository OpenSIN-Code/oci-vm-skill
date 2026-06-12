# OCI Networking

## VCN: sin-supabase-vcn

- **OCID**: `ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaadw6zasqa72csiwcnyzogbo7pf7wkhndclrc4rj3aktikn6oqb64a`
- **CIDR**: `10.16.0.0/16`
- **DNS Label**: `sinsup`
- **Region**: `eu-frankfurt-1`

## Subnet: sin-supabase-public-subnet

- **CIDR**: `10.16.0.0/24`
- **DNS Label**: `publicsub`
- **Prohibit Public IP**: `false` (public subnets allowed)
- **Route Table**: default (with Internet Gateway)

## Public IPs

| IP | Assigned To | Type | State |
|----|-------------|------|-------|
| 92.5.60.87 | sin-supabase VNIC | EPHEMERAL | Attached |
| 92.5.116.158 | (legacy) | EPHEMERAL | Reserved |

## Internet Gateway

- `sin-supabase-igw` (default)

## Security Lists

- Default list allows:
  - TCP 22 (SSH) from 0.0.0.0/0
  - TCP 80, 443, 8006, 8443 from 0.0.0.0/0
  - All internal VCN traffic (10.16.0.0/16)

## Cloudflare Tunnel

- Tunnel ID: `fb25fb11-8840-41fd-8a85-518674c86725`
- Connects: supabase.delqhi.com → VM (Kong 8006)
- NOT public port 8006 — only via tunnel

## Useful commands

```bash
# All VCNs
oci network vcn list --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia

# Subnets
oci network subnet list --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia

# Security lists
oci network security-list list --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia
```
