#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FREEZE_DIR="${ROOT_DIR}/.freeze"
TS="$(date +%Y%m%d_%H%M%S)"
STAMP_DIR="${FREEZE_DIR}/${TS}"
FREEZE_FLAG="${FREEZE_DIR}/ACTIVE"
STATE_SNAPSHOT_LABEL="night-freeze-${TS}"

mkdir -p "$STAMP_DIR"

log() {
  printf '[freeze] %s\n' "$*"
}

capture_state() {
  log "capturing repository state"
  git -C "$ROOT_DIR" status --short > "$STAMP_DIR/git-status.txt" 2>&1 || true
  git -C "$ROOT_DIR" branch -vv > "$STAMP_DIR/git-branch.txt" 2>&1 || true
  git -C "$ROOT_DIR" remote -v > "$STAMP_DIR/git-remote.txt" 2>&1 || true
  if [ -d "$ROOT_DIR/.state" ]; then
    find "$ROOT_DIR/.state" -maxdepth 2 -type f | sort > "$STAMP_DIR/state-files.txt" 2>&1 || true
  fi
  if [ -x "$ROOT_DIR/snapshot/smart_snapshot.sh" ]; then
    bash "$ROOT_DIR/snapshot/smart_snapshot.sh" "$ROOT_DIR/snapshots" "$STATE_SNAPSHOT_LABEL" "$ROOT_DIR" > "$STAMP_DIR/snapshot.txt" 2>&1 || true
  fi
}

freeze_services() {
  log "stopping known automation services if present"
  for unit in audit-vps-agent.service audit-vps-snapshot.timer audit-vps-healthcheck.timer; do
    if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files "$unit" >/dev/null 2>&1; then
      systemctl stop "$unit" > "$STAMP_DIR/${unit}.stop.txt" 2>&1 || true
    fi
  done
}

install_git_push_block() {
  log "installing local pre-push blocker"
  mkdir -p "$ROOT_DIR/.git/hooks"
  cat > "$ROOT_DIR/.git/hooks/pre-push" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(git rev-parse --show-toplevel)"
if [ -f "$ROOT_DIR/.freeze/ACTIVE" ]; then
  echo "Push blocked: night freeze is active on this machine." >&2
  exit 1
fi
EOF
  chmod +x "$ROOT_DIR/.git/hooks/pre-push"
}

write_freeze_flag() {
  log "writing freeze flag"
  cat > "$FREEZE_FLAG" <<EOF
active=true
ts=${TS}
host=$(hostname 2>/dev/null || echo unknown)
user=$(id -un 2>/dev/null || echo unknown)
mode=night-freeze
EOF
}

main() {
  capture_state
  freeze_services
  install_git_push_block
  write_freeze_flag
  log "night freeze enabled"
  log "freeze flag: $FREEZE_FLAG"
}

main "$@"
