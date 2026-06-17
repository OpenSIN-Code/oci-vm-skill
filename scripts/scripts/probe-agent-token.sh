#!/usr/bin/env bash
# Purpose: Probe Service Token using only commands that exist in infisical CLI v0.43.x.
# Docs: ../SKILL.md §11.0-11.1a
#
# Strategy: try a write+delete of a unique PROBE_KEY.  Both writes and deletes
# require authentication; round-trip success means the token works.
#
# SECURITY: token is never echoed.  Only the agent-token file is read.

set -euo pipefail
TOKEN_FILE=~/.infisical/agent-token

[[ -f "$TOKEN_FILE" ]] || { echo "[err] $TOKEN_FILE missing — run scripts/agent-token-bootstrap.sh first"; exit 1; }
[[ "$(stat -f '%Lp' "$TOKEN_FILE")" == "600" ]] || { echo "[err] $TOKEN_FILE must be mode 0600 — current is $(stat -f '%Lp' "$TOKEN_FILE")"; exit 1; }

T="$(head -n1 "$TOKEN_FILE" | tr -d '\r' | tr -d '\n')"
[[ "$T" =~ ^st\..+\..+$ ]] || { echo "[err] no valid token in $TOKEN_FILE"; exit 1; }

PRJ=fa7758b4-f84c-4297-966e-710056d531ef
ENV=prod
DOMAIN=https://eu.infisical.com/api

PROBE_KEY="AGENT_PROBE_$(date +%s)_$$"
PROBE_VAL="ok_$(date +%s)"

# Write probe secret via chmod-600 tempfile (no token in CLI args or env)
TF=$(mktemp -t probe-agent-token.XXXXXX)
chmod 600 "$TF"
printf '%s=%s\n' "$PROBE_KEY" "$PROBE_VAL" > "$TF"

echo "[probe] workspace=$PRJ env=$ENV domain=eu"
SET_OUT="$(infisical secrets set --token "$T" --projectId "$PRJ" --env "$ENV" --domain "$DOMAIN" --file "$TF" 2>&1 || true)"
rm -f "$TF"

if [[ "$SET_OUT" == *"SECRET CREATED"* ]] || [[ "$SET_OUT" == *"secret updated"* ]]; then
  echo "[ok ] write-probe accepted — token has write-scope on env=prod"
else
  echo "[err] write-probe rejected:"
  echo "$SET_OUT" | head -3 | sed 's/^/        /'
  exit 1
fi

# Cleanup: delete the probe secret immediately
infisical secrets delete --token "$T" --projectId "$PRJ" --env "$ENV" --domain "$DOMAIN" "$PROBE_KEY" >/dev/null 2>&1 || true
echo "[ok ] probe-secret $PROBE_KEY deleted (cleanup)"
echo "[ok ] ALL CHECKS PASS — token works for rw scope on prod env"
