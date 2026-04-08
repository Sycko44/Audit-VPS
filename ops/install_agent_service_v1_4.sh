#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PULL_V3="${ROOT_DIR}/transport/pull_job_bundle_v3.sh"
PULL_DST="${ROOT_DIR}/transport/pull_job_bundle.sh"
SERVICE_SRC="${ROOT_DIR}/systemd/audit-vps-agent-v1_3.service"
SERVICE_DST="/etc/systemd/system/audit-vps-agent.service"

log() {
  printf '[install-agent-v1.4] %s\n' "$*"
}

[ -f "$PULL_V3" ] || { echo "missing pull v3 script" >&2; exit 2; }
[ -f "$SERVICE_SRC" ] || { echo "missing service template" >&2; exit 2; }

cp "$PULL_V3" "$PULL_DST"
chmod +x "$PULL_DST"
log "installed pull_job_bundle v3"

rm -rf "$HOME/.audit-vps-agent/inbox/.pull_tmp" 2>/dev/null || true
log "cleaned legacy inbox .pull_tmp if present"

sudo cp "$SERVICE_SRC" "$SERVICE_DST"
sudo systemctl daemon-reload
sudo systemctl enable audit-vps-agent.service
sudo systemctl restart audit-vps-agent.service
sleep 2
sudo systemctl --no-pager --full status audit-vps-agent.service || true

STAMP="stable-state-$(date +%Y%m%d_%H%M%S)"
if [ -x "$ROOT_DIR/snapshot/smart_snapshot.sh" ]; then
  bash "$ROOT_DIR/snapshot/smart_snapshot.sh" "$ROOT_DIR/snapshots" "$STAMP" "$ROOT_DIR" >/dev/null 2>&1 || true
  log "stable snapshot created: $ROOT_DIR/snapshots/$STAMP"
fi

log "installation complete"
log "check logs with: journalctl -u audit-vps-agent.service -n 100 --no-pager"
