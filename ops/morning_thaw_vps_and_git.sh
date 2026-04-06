#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FREEZE_FLAG="${ROOT_DIR}/.freeze/ACTIVE"

log() {
  printf '[thaw] %s\n' "$*"
}

remove_freeze_flag() {
  if [ -f "$FREEZE_FLAG" ]; then
    rm -f "$FREEZE_FLAG"
    log "freeze flag removed"
  fi
}

start_services() {
  log "starting known automation services if present"
  for unit in audit-vps-agent.service audit-vps-snapshot.timer audit-vps-healthcheck.timer; do
    if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files "$unit" >/dev/null 2>&1; then
      systemctl start "$unit" >/dev/null 2>&1 || true
    fi
  done
}

main() {
  remove_freeze_flag
  start_services
  log "morning thaw completed"
}

main "$@"
