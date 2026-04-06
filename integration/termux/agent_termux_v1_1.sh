#!/usr/bin/env bash
set -Eeuo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ENV_FILE:-${BASE_DIR}/transport/job.env.example}"
[ -f "$ENV_FILE" ] && . "$ENV_FILE"

: "${HUB_HOST:=pulseo.me}"
: "${POLL:=30}"

WORK_ROOT="${WORK_ROOT:-$HOME/.audit-vps-agent}"
INBOX="${WORK_ROOT}/inbox"
EXECUTED="${WORK_ROOT}/executed"
RECEIPTS="${WORK_ROOT}/receipts"
LOGS="${WORK_ROOT}/logs"
PUBKEY="${PUBKEY:-${WORK_ROOT}/keys/trustplane.pub}"

mkdir -p "$INBOX" "$EXECUTED" "$RECEIPTS" "$LOGS"

log() {
  printf '[%s] %s\n' "$(date -Is)" "$*" | tee -a "${LOGS}/agent.log"
}

pull_jobs() {
  log "Pulling jobs from ${HUB_HOST}"
  bash "${BASE_DIR}/transport/pull_job_bundle.sh" "$ENV_FILE" "$INBOX" || log "pull failed"
}

process_job_dir() {
  local job_dir="$1"
  local manifest="${job_dir}/manifest.json"
  local sig="${job_dir}/manifest.sig"
  local payload="${job_dir}/payload.sh"
  local decision="${job_dir}/decision.json"
  local receipt="${RECEIPTS}/$(basename "$job_dir")-receipt.json"

  [ -d "$job_dir" ] || return 0
  [ -f "$payload" ] || { log "skip $(basename "$job_dir"): missing payload"; return 0; }

  bash "${BASE_DIR}/security_core/verify_manifest.sh" "$manifest" || { log "manifest verify failed for $job_dir"; return 0; }
  bash "${BASE_DIR}/security_core/verify_signature.sh" "$manifest" "$sig" "$PUBKEY" || { log "signature verify failed for $job_dir"; return 0; }
  bash "${BASE_DIR}/security_core/policy_gate.sh" "$manifest" "$decision"

  if grep -q '"allow": true' "$decision" 2>/dev/null; then
    log "policy allowed $(basename "$job_dir")"
    chmod +x "$payload" 2>/dev/null || true
    if bash "$payload" >"${job_dir}/payload.stdout.log" 2>"${job_dir}/payload.stderr.log"; then
      bash "${BASE_DIR}/security_core/write_receipt.sh" "$(basename "$job_dir")" success "$receipt"
    else
      bash "${BASE_DIR}/security_core/write_receipt.sh" "$(basename "$job_dir")" failure "$receipt"
    fi
  else
    log "policy denied $(basename "$job_dir")"
    bash "${BASE_DIR}/security_core/write_receipt.sh" "$(basename "$job_dir")" denied "$receipt"
  fi

  bash "${BASE_DIR}/transport/push_receipt.sh" "$ENV_FILE" "$receipt" || log "receipt push failed for $job_dir"
  mv "$job_dir" "$EXECUTED/" 2>/dev/null || true
}

scan_once() {
  pull_jobs
  find "$INBOX" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while IFS= read -r d; do
    process_job_dir "$d"
  done
}

main() {
  log "Agent started with HUB_HOST=${HUB_HOST}"
  while true; do
    scan_once
    sleep "$POLL"
  done
}

main "$@"
