#!/bin/bash
# OCI Always Free Tier Capacity check
# Usage: ./capacity.sh [ad]
# Docs: SKILL.md

set -euo pipefail

AD="${1:-PjAL:EU-FRANKFURT-1-AD-1}"
REGION="${2:-eu-frankfurt-1}"
TENANCY="ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia"

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║           OCI Always Free Tier Capacity ($AD)"
echo "╠════════════════════════════════════════════════════════════════════╣"
echo ""

check_limit() {
  local limit_name="$1"
  local label="$2"
  local result
  result=$(oci limits resource-availability get \
    --compartment-id "$TENANCY" \
    --service-name compute \
    --limit-name "$limit_name" \
    --availability-domain "$AD" \
    --region "$REGION" \
    --output json 2>/dev/null)
  if [ -n "$result" ]; then
    local available=$(echo "$result" | python3 -c "import json, sys; d=json.load(sys.stdin); print(d['data'].get('available', 'N/A'))" 2>/dev/null)
    local used=$(echo "$result" | python3 -c "import json, sys; d=json.load(sys.stdin); print(d['data'].get('used', 'N/A'))" 2>/dev/null)
    printf "  %-30s: %s free / %s used\n" "$label" "$available" "$used"
  else
    printf "  %-30s: ERROR\n" "$label"
  fi
}

echo "A1 (ARM Ampere — Always Free, 250 OCPU per AD):"
check_limit "standard-a1-core-count" "A1.OCPU (cores)"
check_limit "standard-a1-memory-count" "A1.Memory (GB)"

echo ""
echo "E2 (Intel x86 — Always Free, 2 Micro per tenant):"
check_limit "vm-standard-e2-1-micro-count" "E2.1.Micro (count)"

echo ""
echo "Boot volumes (Always Free 200 GB per A1 VM):"
for vm in sin-supabase A2A-SIN-Token-Blackbox; do
  echo "  $vm:"
  oci compute boot-volume-attachment list \
    --compartment-id "$TENANCY" \
    --availability-domain "$AD" \
    --region "$REGION" \
    --query "data[?\"instance-display-name\"=='$vm'].\"boot-volume-id\"" \
    --output table 2>/dev/null | head -3
done
