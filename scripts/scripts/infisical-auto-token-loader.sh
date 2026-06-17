#!/usr/bin/env bash
# Purpose: sourceable auto-loader for ~/.infisical/agent-token.
# Adds INFISICAL_TOKEN to the current shell WITHOUT typing/echoing it.
# Usage:
#   . ~/.../scripts/infisical-auto-token-loader.sh        # in .zshrc / .bashrc
#   eval "$(~/.../scripts/infisical-auto-token-loader.sh --print-env)"
F=~/.infisical/agent-token
[[ ! -f "$F" ]] && return 0 2>/dev/null
[[ "$(stat -f '%Lp' "$F" 2>/dev/null)" != "600" ]] && return 0 2>/dev/null
T="$(head -n1 "$F" 2>/dev/null | tr -d '\r' | tr -d '\n')"
[[ "$T" =~ ^st\..+\..+$ ]] || return 0 2>/dev/null
if [[ "${1:-}" == "--print-env" ]]; then
  printf 'export INFISICAL_TOKEN=%q\n' "$T"
else
  export INFISICAL_TOKEN="$T"
fi
