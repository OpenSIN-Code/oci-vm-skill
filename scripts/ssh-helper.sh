#!/bin/bash
# OCI VM SSH helper
# Usage: ./ssh-helper.sh <vm-name> [command]
# Docs: SKILL.md

set -euo pipefail

VM="${1:-}"
CMD="${2:-}"

case "$VM" in
  sin-supabase)
    HOST="92.5.60.87"
    KEY="$HOME/.ssh/id_ed25519"
    USER="ubuntu"
    ;;
  A2A-SIN-Token-Blackbox|A2A*)
    # No public IP; need a jump host or port forwarding
    echo "⚠️  $VM has no public IP. Use sin-supabase as jump host:"
    echo "   ssh -i ~/.ssh/id_ed25519 -J ubuntu@92.5.60.87 ubuntu@<private-ip>"
    exit 1
    ;;
  *)
    echo "Usage: $0 <vm-name> [command]"
    echo ""
    echo "Available VMs:"
    echo "  sin-supabase   — 92.5.60.87 (primary Supabase VM)"
    echo "  A2A-SIN-Token-Blackbox — no public IP, use jump host"
    exit 1
    ;;
esac

if [ -n "$CMD" ]; then
  ssh -i "$KEY" "$USER@$HOST" "$CMD"
else
  ssh -i "$KEY" "$USER@$HOST"
fi
