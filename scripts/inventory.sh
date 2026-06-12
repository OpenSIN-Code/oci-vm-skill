#!/bin/bash
# OCI VM Inventory — list all running instances
# Usage: ./inventory.sh [region]
# Docs: SKILL.md

set -euo pipefail

REGION="${1:-eu-frankfurt-1}"
TENANCY="ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia"

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                  OCI VM Inventory ($REGION)"
echo "╠════════════════════════════════════════════════════════════════════╣"
echo ""

oci compute instance list \
  --compartment-id "$TENANCY" \
  --region "$REGION" \
  --query "data[*].{
    Name:\"display-name\",
    State:\"lifecycle-state\",
    Shape:\"shape\",
    OCPU:\"shape-config\".\"ocpus\",
    MemoryGB:\"shape-config\".\"memory-in-gbs\",
    AD:\"availability-domain\",
    Created:\"time-created\"
  }" \
  --output table

echo ""
echo "Public IPs:"
oci network public-ip list \
  --compartment-id "$TENANCY" \
  --scope AVAILABILITY_DOMAIN \
  --availability-domain "PjAL:EU-FRANKFURT-1-AD-1" \
  --region "$REGION" \
  --query "data[*].{IP:\"ip-address\",Assigned:\"lifetime\"}" \
  --output table
