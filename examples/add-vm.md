# Add a new Always Free A1 VM

## Goal

Provision a new ARM A1 VM in the **free AD-2** (250 OCPU available) — keeps sin-supabase isolated in AD-1.

## Steps

### 1. Find an Ubuntu 22.04 ARM image

```bash
TENANCY="ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia"
oci compute image list \
  --compartment-id "$TENANCY" \
  --operating-system "Canonical Ubuntu" \
  --operating-system-version "22.04" \
  --shape "VM.Standard.A1.Flex" \
  --region eu-frankfurt-1 \
  --query "data[?\"lifecycle-state\"=='AVAILABLE'] | [0].id" \
  --raw-output
```

### 2. Create the instance (in AD-2 for isolation)

```bash
oci compute instance launch \
  --compartment-id "$TENANCY" \
  --availability-domain "PjAL:EU-FRANKFURT-1-AD-2" \
  --shape "VM.Standard.A1.Flex" \
  --shape-config '{"ocpus": 4, "memoryInGBs": 24}' \
  --image-id "<image-ocid-from-step-1>" \
  --subnet-id "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaadw6zasqa72csiwcnyzogbo7pf7wkhndclrc4rj3aktikn6oqb64a" \
  --display-name "my-new-vm" \
  --assign-public-ip true \
  --metadata "{\"ssh_authorized_keys\": \"$(cat ~/.ssh/id_ed25519.pub)\"}"
```

### 3. Wait for running state

```bash
oci compute instance get --instance-id <new-vm-ocid> --wait-for-state RUNNING
```

### 4. Get the public IP

```bash
oci compute instance list-vnics --instance-id <new-vm-ocid> \
  --query "data[0].\"public-ip\"" --raw-output
```

### 5. SSH in

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@<new-public-ip>
```

## Cost

**Always Free** — 0 € for as long as A1 quota allows. Currently AD-2 has 250 OCPU / 1666 GB fully free.

## Rules

- **Do not exceed 4 OCPU per VM** (limit per shape)
- **Do not exceed 24 GB RAM per VM**
- **Do not provision in AD-1** — that's for sin-supabase
- **Do not attach Block Volumes** beyond 200 GB per A1 VM (Always Free)
