#!/usr/bin/env bash
set -Eeuo pipefail

write_receipt_final() {
  local status="$1"
  local exit_code="$2"
  local out="${STATE_DIR}/final-receipt.json"
  local started="${RUN_STARTED_AT:-$(date -Is)}"
  local finished
  finished="$(date -Is)"

  cat > "$out" <<EOF
{
  "run_id": "$RUN_ID",
  "mode": "$MODE",
  "status": "$status",
  "exit_code": $exit_code,
  "state_dir": "$STATE_DIR",
  "started_at": "$started",
  "finished_at": "$finished"
}
EOF
  log_info "final receipt written to ${out}"
}
