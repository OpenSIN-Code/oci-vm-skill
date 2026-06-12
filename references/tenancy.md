# OCI Tenancy

## OCI Account

- **Tenancy OCID**: `ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia`
- **Region**: `eu-frankfurt-1`
- **Home Region**: `eu-frankfurt-1`
- **Plan**: Free Tier (Always Free eligible)

## Users

- `info@zukunftsorientierte-energie.de` (admin)

## OCI Config (local)

```ini
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaageunwvewwzuhfr6d7u2r224efrc6auzljmuqjum4ds2oheb73tva
fingerprint=c2:68:54:f5:4c:85:0f:07:29:47:54:31:00:4b:98:e5
tenancy=ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia
region=eu-frankfurt-1
key_file=/Users/jeremy/.oci/oci_api_key.pem
```

## API Keys (local)

- `~/.oci/oci_api_key.pem` (private, mode 600)
- `~/.oci/oci_api_key_public.pem` (public, registered with IAM)

## Availability Domains (Frankfurt)

- `PjAL:EU-FRANKFURT-1-AD-1` — **USED** (sin-supabase + A2A)
- `PjAL:EU-FRANKFURT-1-AD-2` — **FREE**
- `PjAL:EU-FRANKFURT-1-AD-3` — **FREE**

## IAM Groups

(tbd — fetch with `oci iam group list`)

## IAM Policies

(tbd — fetch with `oci iam policy list --compartment-id <tenancy>`)

## Useful commands

```bash
# Current user
oci iam user get --user-id ocid1.user.oc1..aaaaaaaageunwvewwzuhfr6d7u2r224efrc6auzljmuqjum4ds2oheb73tva

# All groups
oci iam group list --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia

# All policies
oci iam policy list --compartment-id ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia
```
