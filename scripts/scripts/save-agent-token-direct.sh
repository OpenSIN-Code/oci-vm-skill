#!/usr/bin/env bash
# Purpose: Replacement for agent-token-bootstrap.sh — atomic single-write, no tmp+rename.
# Docs: ../SKILL.md §11.0-11.1a
set -euo pipefail
F=~/.infisical/agent-token

usage() { sed -n '/^# Purpose:/,/^set -euo/p' "$0" | head -n 8; }
[ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && { usage; exit 0; }
[ "${1:-}" = "--file="* ] && STAGE="${1#--file=}" || {
  echo "usage: $0 --file=<0600-path-with-token>" >&2
  exit 1
}
[ -f "$STAGE" ] || { echo "[err] stage file missing: $STAGE" >&2; exit 1; }

# Read token — single line, strict format
T="$(grep -oE '^st\.[a-zA-Z0-9-]+\.[a-zA-Z0-9._-]+' "$STAGE" 2>/dev/null | head -n1 | tr -d '[:space:]')"
[ -n "$T" ] || { echo "[err] no token matching st.<UUID>.<random> in $STAGE" >&2; exit 3; }
[ "${#T}" -ge 50 ] || { echo "[err] token too short (${#T} chars), seems invalid" >&2; exit 3; }
echo "[ok ] token parsed (length=${#T})"

# Atomic single-write: cat-heredoc directly to $F (no /tmp mv)
{
  echo "# ~/.infisical/agent-token — canonical non-interactive Infisical Service Token"
  echo "# Generated: $(date -u +%FT%TZ) via save-agent-token-direct.sh"
  echo "# Format:    st.<UUID>.<random>"
  echo "# Mode:      0600 — NEVER cat this file. Use scripts/decode-agent-token.sh instead."
  echo
  echo "$T"
} > "$F"
chmod 600 "$F"
echo "[ok ] token saved → $F (mode 0600)"

# Probe (uses no-log, never echoes token)
PRJ=fa7758b4-f84c-4297-966e-710056d531ef
ENV=prod
DOMAIN=https://eu.infisical.com/api
RAW="$(infisical secrets list --token "$T" --projectId "$PRJ" --env "$ENV" --domain "$DOMAIN" --silent --output json 2>&1 || true)"
RC=$?
COUNT="$(printf '%s' "$RAW" | python3 -c "import sys,json;print(len(json.load(sys.stdin)))" 2>/dev/null || echo -1)"
if [ "$RC" -ne 0 ] || [ "$COUNT" -lt 1 ]; then
  echo "[warn] probe failed (rc=$RC, count=$COUNT) — token might be wrong/expired" >&2
  echo "        re-check in Infisical WebUI → Project Settings → Service Tokens" >&2
  # Don't bail — token may still be valid for future use
  exit 0
fi
echo "[ok ] probe: $COUNT secrets visible — token works"
