# Purpose: Decode the canonical agent Service Token into an env var without ever printing it.
# Docs: ../skill-oci-oracle-cloud SKILL.md §11.a
#
# Usage in OTHER scripts:
#   eval "$(~/.../scripts/decode-agent-token.sh)"        # sets INFISICAL_TOKEN in current shell
#   $(~/.../scripts/decode-agent-token.sh --print-env)"   # prints as shell-executable line
#
# NEVER call this script from a context that logs the shell variable. The
# agent must use infisical CLI + --token flag, never `echo $INFISICAL_TOKEN`.

set -euo pipefail
F=~/.infisical/agent-token

[[ -f "$F" ]] || { echo "[err] $F missing — run scripts/agent-token-bootstrap.sh first" >&2; exit 1; }
[[ "$(stat -f '%Lp' "$F")" == "600" ]] || { echo "[err] $F must be mode 0600 (current is $(stat -f '%Lp' "$F"))" >&2; exit 1; }

TOKEN="$(grep -E '^st\.' "$F" | head -n1 | tr -d '[:space:]')"
[[ "$TOKEN" =~ ^st\..+\..+$ ]] || { echo "[err] no valid token in $F" >&2; exit 1; }

if [[ "${1:-}" == "--print-env" ]]; then
  printf 'export INFISICAL_TOKEN=%q\n' "$TOKEN"
else
  export INFISICAL_TOKEN="$TOKEN"
fi
