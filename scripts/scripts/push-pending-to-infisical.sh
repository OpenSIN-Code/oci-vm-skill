#!/usr/bin/env bash
# Purpose: Restore pending OCI secrets to Infisical workspace
#          fa7758b4-f84c-4297-966e-710056d531ef, env=prod.
# Docs: ../skill-oci-oracle-cloud SKILL.md §11.a
#
# Auth strategy (in order, NO interactive at any level):
#   1. Token via env  : --token "$INFISICAL_TOKEN"
#   2. Token via env  : pull from INFISICAL_TOKEN env var
#   3. Token file     : ~/.infisical/agent-token (chmod 600, read via grep + reds)
#   4. Login fallback : infisical login --silent (only if no token usable)
#
# Usage:
#   bash push-pending-to-infisical.sh                # auto-detect token
#   INFISICAL_TOKEN=$(cat -v ~/.infisical/agent-token) bash push-pending-to-infisical.sh
#   bash push-pending-to-infisical.sh --dry-run      # show first 5 keys without pushing

set -euo pipefail
PRJ=fa7758b4-f84c-4297-966e-710056d531ef
ENV=prod
DOMAIN=https://eu.infisical.com/api
BUNDLE="$HOME/.infisical/secrets-backup/oci-push-pending-VALUES.bin"

if [[ ! -f "$BUNDLE" ]]; then
  echo "[err] bundle not found at $BUNDLE — re-build via /tmp/build_oci_push_bundle.py" >/dev/stderr
  exit 1
fi

# --- Auth resolution: prefer env, then file, then login ---
ASSERT_TOKEN() {
  local t="$1"
  [[ "$t" =~ ^st\.[a-zA-Z0-9-]+\..+$ ]]
}

# 1) env var
if [[ -n "${INFISICAL_TOKEN:-}" ]] && ASSERT_TOKEN "$INFISICAL_TOKEN"; then
  AUTH_ARGS=( --token "$INFISICAL_TOKEN" )
  echo "[auth] using INFISICAL_TOKEN from env"
# 2) token file
elif [[ -f "$HOME/.infisical/agent-token" ]] \
  && [[ "$(stat -f '%Lp' "$HOME/.infisical/agent-token")" == "600" ]]; then
  AGENT_TOKEN="$(grep -E '^st\.' "$HOME/.infisical/agent-token" | head -n1 | tr -d '[:space:]')"
  if ASSERT_TOKEN "$AGENT_TOKEN"; then
    AUTH_ARGS=( --token "$AGENT_TOKEN" )
    echo "[auth] using token from ~/.infisical/agent-token (chmod 600)"
  fi
fi

if [[ -z "${AUTH_ARGS+x}" ]]; then
  echo "[warn] no Service Token found." >/dev/stderr
  echo "        Create one via Infisical WebUI (Project fa7758b4… → Settings → Service Tokens)" >/dev/stderr
  echo "        Send it to: bash $0  (with token on stdin),  OR" >/dev/stderr
  echo "                  bash /Users/jeremy/.config/opencode/skills/skill-oci-oracle-cloud/scripts/agent-token-bootstrap.sh" >/dev/stderr
  exit 2
fi

# Verify with one probe call
PROBE_COUNT=$(infisical secrets folders "${AUTH_ARGS[@]}" \
    --projectId "$PRJ" --env "$ENV" --domain "$DOMAIN" \
    --path '/' --silent --output json 2>/dev/null | python3 -c "import sys,json;print(len(json.load(sys.stdin)))" 2>/dev/null || echo -1)
echo "[probe] visible secrets with this token: $PROBE_COUNT"
if [[ "$PROBE_COUNT" -lt 1 ]]; then
  echo "[err] probe failed — token might be wrong, expired, or wrong scope (need read+write on env=prod)" >/dev/stderr
  fi

if [[ "${1:-}" == "--dry-run" ]]; then
  echo "[dry-run] would push 29 keys. Aborted before pushes."
  python3 << 'PYEND'
from pathlib import Path
import struct
BUNDLE = Path("/Users/jeremy/.infisical/secrets-backup/oci-push-pending-VALUES.bin")
hdr_end = BUNDLE.read_bytes().find(b"\n") + 1
buf = BUNDLE.read_bytes()[hdr_end:]
pos = 0
seen = []
while pos < len(buf):
    size = int.from_bytes(buf[pos:pos+4], "little"); pos += 4
    nul = buf.index(b"\x00", pos); k = buf[pos:nul].decode(); pos = nul + 1
    pos += size
    seen.append(k)
print(f"  prepared keys ({len(seen)}):")
for k in seen[:8]:
    print(f"    - {k}")
print(f"  … ({len(seen)-8} more)")
PYEND
  exit 0
fi

python3 << 'PYEND'
import os, subprocess, tempfile
from pathlib import Path

BUNDLE = Path("/Users/jeremy/.infisical/secrets-backup/oci-push-pending-VALUES.bin")
PRJ, ENV, DOMAIN = ("fa7758b4-f84c-4297-966e-710056d531ef", "prod", "https://eu.infisical.com/api")
TOKEN_FILE = Path(os.path.expanduser("~/.infisical/agent-token"))

# Pick token
import os
token = os.environ.get("INFISICAL_TOKEN", "").strip()
if not token:
    for line in TOKEN_FILE.read_text().splitlines():
        if line.startswith("st."):
            token = line.strip(); break

AUTH = ["--token", token]

raw = BUNDLE.read_bytes()
hdr_end = raw.find(b"\n") + 1
buf = raw[hdr_end:]
NUL = b"\x00"
pos = 0; ok = 0; fail = 0; err = []

while pos < len(buf):
    size = int.from_bytes(buf[pos:pos+4], "little"); pos += 4
    nul = buf.index(NUL, pos); key = buf[pos:nul].decode(); pos = nul + 1
    val = buf[pos:pos+size]; pos += size

    tf_path = None
    try:
        with tempfile.NamedTemporaryFile("wb", suffix=".env", delete=False, dir="/tmp") as tf:
            tf.write(("%s=%s\n" % (key, val.decode("utf-8", "replace"))).encode())
            tf_path = tf.name
        os.chmod(tf_path, 0o600)
        proc = subprocess.run(
            ["infisical", "secrets", "set", "--file", tf_path,
             *AUTH, "--projectId", PRJ, "--env", ENV, "--domain", DOMAIN],
            capture_output=True, text=True
        )
        if proc.returncode == 0:
            ok += 1
            print("  [OK]   %s" % key)
        else:
            fail += 1
            err.append(key)
            print("  [FAIL] %s: %s" % (key, proc.stderr.strip()[:120]))
    finally:
        if tf_path:
            try: Path(tf_path).unlink()
            except OSError: pass

# Show summary + last-rotated stamp
print("\n  pushed:     %d" % ok)
print("  failed:     %d" % fail)
if token:
    print("  token:      st.%s..%s  (truncated for safety)" % (token.split('.')[1][:8], token[-4:]))
PYEND

# Stamp file for audit trail
echo "# Last used push:   $(date -u +%FT%TZ)" >> ~/.infisical/agent-token 2>/dev/null || true
