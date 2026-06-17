# oci-vm-skill — OCI / Oracle Cloud / VM / Tunnel / Secrets Skill

Single source of truth for ALL OCI / Oracle Cloud / VM / Tunnel / Cloudflared / Infisical work.

## Contents

- `SKILL.md` — 1250 lines, §0–§21 (inventory, tunnel map, recovery, deployment, autonomous access)
- `scripts/` — Infisical helpers, VM bootstrap, emergency recovery
- `references/` — Tenancy, networking, SSH keys, storage

## Live-verified 2026-06-17

- 2 OCI VMs: `sin-blackbox` (92.5.116.158) + `sin-supabase` (92.5.60.87)
- OpenSIN-Chat deployed on sin-supabase, sinchat.delqhi.com live (HTTP 200)
- Cloudflare tunnel migrated from Mac to OCI
- Full autonomous agent SSH access

## Installation

```bash
# As opencode skill
cp -r . ~/.config/opencode/skills/skill-oci-oracle-cloud/
```

## License

MIT
