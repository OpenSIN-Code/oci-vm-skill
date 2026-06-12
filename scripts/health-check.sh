#!/bin/bash
# OCI VM Health check
# Usage: ./health-check.sh
# Docs: SKILL.md

set -uo pipefail

REGION="${1:-eu-frankfurt-1}"
TENANCY="ocid1.tenancy.oc1..aaaaaaaazadryqy3edvllu5hbvucfalkxetdqqiiss2v24vni2fjapmnosia"

echo "=== OCI VM Health Check ==="
echo ""

# Check VMs in console
echo "1. Console state:"
oci compute instance list \
  --compartment-id "$TENANCY" \
  --region "$REGION" \
  --query "data[*].{Name:\"display-name\",State:\"lifecycle-state\"}" \
  --output table

# Check SSH reachability
echo ""
echo "2. SSH reachability:"
for endpoint in "92.5.60.87:22"; do
  host="${endpoint%:*}"
  port="${endpoint#*:}"
  if nc -zv -w 5 "$host" "$port" 2>&1 | grep -q "succeeded"; then
    echo "  ✓ $host:$port OPEN"
  else
    echo "  ✗ $host:$port FAILED"
  fi
done

# Check running services
echo ""
echo "3. Services on sin-supabase (via SSH):"
if ssh -o ConnectTimeout=5 -i "$HOME/.ssh/id_ed25519" "ubuntu@92.5.60.87" "docker ps --format 'table {{.Names}}\t{{.Status}}' 2>/dev/null | head -15" 2>/dev/null; then
  :
else
  echo "  ⚠️  SSH failed or docker not available"
fi

# Check capacity
echo ""
echo "4. Capacity check (AD-1):"
result=$(oci limits resource-availability get \
  --compartment-id "$TENANCY" \
  --service-name compute \
  --limit-name "standard-a1-core-count" \
  --availability-domain "PjAL:EU-FRANKFURT-1-AD-1" \
  --region "$REGION" \
  --output json 2>/dev/null)
if [ -n "$result" ]; then
  avail=$(echo "$result" | python3 -c "import json, sys; d=json.load(sys.stdin); print(d['data'].get('available', 'N/A'))" 2>/dev/null)
  echo "  A1.OCPU free in AD-1: $avail / 250"
fi
