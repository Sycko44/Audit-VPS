#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE_SRC="${ROOT_DIR}/systemd/audit-vps-agent.service"
SERVICE_DST="/etc/systemd/system/audit-vps-agent.service"
PULL_V2="${ROOT_DIR}/transport/pull_job_bundle_v2.sh"
PULL_DST="${ROOT_DIR}/transport/pull_job_bundle.sh"
ENV_LOCAL="${ROOT_DIR}/transport/job.env.local"

log() {
  printf '[install-agent-service] %s\n' "$*"
}

[ -f "$SERVICE_SRC" ] || { echo "missing service template" >&2; exit 2; }
[ -f "$PULL_V2" ] || { echo "missing pull v2 script" >&2; exit 2; }

if [ ! -f "$ENV_LOCAL" ]; then
  cat > "$ENV_LOCAL" <<'EOF'
HUB_HOST="pulseo.me"
HUB_PORT="22"
HUB_USER="ubuntu"
HUB_BASE_DIR="/home/ubuntu/agent_hub"
HUB_JOB_DIR="/home/ubuntu/agent_hub/jobs"
HUB_RECEIPT_DIR="/home/ubuntu/agent_hub/receipts"
HUB_REPORT_DIR="/home/ubuntu/agent_hub/reports"
HUB_HOST_FALLBACK=""
POLL="30"
EOF
  log "created transport/job.env.local"
fi

mkdir -p "$HOME/agent_hub/jobs" "$HOME/agent_hub/receipts" "$HOME/agent_hub/reports"
mkdir -p "$HOME/.audit-vps-agent/inbox" "$HOME/.audit-vps-agent/executed" "$HOME/.audit-vps-agent/receipts" "$HOME/.audit-vps-agent/logs"

cp "$PULL_V2" "$PULL_DST"
chmod +x "$PULL_DST"
log "installed fixed pull_job_bundle.sh"

if [ -d "$HOME/.audit-vps-agent/inbox/jobs" ]; then
  shopt -s nullglob
  for d in "$HOME/.audit-vps-agent/inbox/jobs/"*; do
    [ -d "$d" ] || continue
    base="$(basename "$d")"
    if [ ! -e "$HOME/.audit-vps-agent/inbox/$base" ]; then
      mv "$d" "$HOME/.audit-vps-agent/inbox/$base"
      log "flattened inbox wrapper for $base"
    fi
  done
  shopt -u nullglob
  rmdir "$HOME/.audit-vps-agent/inbox/jobs" 2>/dev/null || true
fi

sudo cp "$SERVICE_SRC" "$SERVICE_DST"
sudo systemctl daemon-reload
sudo systemctl enable audit-vps-agent.service
sudo systemctl restart audit-vps-agent.service
sleep 2
sudo systemctl --no-pager --full status audit-vps-agent.service || true

log "installation complete"
log "check logs with: journalctl -u audit-vps-agent.service -n 100 --no-pager"
