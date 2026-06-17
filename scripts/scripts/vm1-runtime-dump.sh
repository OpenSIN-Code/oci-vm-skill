#!/usr/bin/env bash
set -euo pipefail
echo "============ sin-blackbox runtime dump ============"
echo "Hostname / OS"
ssh sin-blackbox 'hostname; cat /etc/os-release | head -5'
echo
echo "Linux kernel + uptime"
ssh sin-blackbox 'uname -a; uptime'
echo
echo "Memory + disk"
ssh sin-blackbox 'free -h; df -h / | tail -2'
echo
echo "Listening TCP ports (top 15)"
ssh sin-blackbox 'ss -tlnp | head -20'
echo
echo "Docker containers + docker images"
ssh sin-blackbox 'docker ps -a; echo ---; docker images --format "{{.Repository}}:{{.Tag}} {{.Size}}" | head -10'
echo
echo "systemd enabled + actively running (top 30)"
ssh sin-blackbox 'systemctl list-units --type=service --state=running --no-pager | head -30'
echo
echo "systemd with cloudflared / sinchat in name"
ssh sin-blackbox 'systemctl list-unit-files | grep -E "cloudflared|sinchat|watchdog|healthcheck|n8n" 2>/dev/null || echo "[info] none of cloudflared|sinchat|watchdog|healthcheck|n8n found"'
echo
echo "cloudflared tunnel-status + DNS state"
ssh sin-blackbox 'pgrep -af cloudflared; echo ---; sudo cloudflared tunnel info opensin 2>&1 | head -10 || echo "[info] cloudflared-tunnel-info unavailable"'
echo
echo "/opt /srv /home listing (one-liner)"
ssh sin-blackbox 'ls -ld /opt/* /srv/* /home/ubuntu 2>/dev/null'
echo
echo "Installed sinchat-watchdog + healthcheck?"
ssh sin-blackbox 'test -f /usr/local/bin/cloudflared-watchdog.sh && echo cloudflared-watchdog.sh: PRESENT || echo cloudflared-watchdog.sh: MISSING
test -f /usr/local/bin/sinchat-healthcheck.sh && echo sinchat-healthcheck.sh: PRESENT || echo sinchat-healthcheck.sh: MISSING
systemctl is-enabled cloudflared-watchdog 2>/dev/null || echo cloudflared-watchdog.service: not-enabled
systemctl is-enabled sinchat-healthcheck.timer 2>/dev/null || echo sinchat-healthcheck.timer: not-enabled'
echo "=========================================="
