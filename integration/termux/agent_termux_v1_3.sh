#!/usr/bin/env bash
set -Eeuo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ENV_FILE:-${BASE_DIR}/transport/job.env.local}"
[ -f "$ENV_FILE" ] && . "$ENV_FILE"

: "${HUB_HOST:=pulseo.me}"
: "${POLL:=30}"
: "${AGENT_ID:=termux-agent}"
: "${ALLOWED_SIGNERS:=${HOME}/.audit-vps-agent/keys/allowed_signers}"

WORK_ROOT="${WORK_ROOT:-$HOME/.audit-vps-agent}"
INBOX="${WORK_ROOT}/inbox"
EXECUTED="${WORK_ROOT}/executed"
RECEIPTS="${WORK_ROOT}/receipts"
LOGS="${WORK_ROOT}/logs"

mkdir -p "$INBOX" "$EXECUTED" "$RECEIPTS" "$LOGS"

log() {
  printf '[%s] %s\n' "$(date -Is)" "$*" | tee -a "${LOGS}/agent.log"
}

sha256_of() {
  sha256sum "$1" | awk '{print $1}'
}

pull_jobs() {
  bash "${BASE_DIR}/transport/pull_job_bundle.sh" "$ENV_FILE" "$INBOX"
}

job_already_processed() {
  local job_dir="$1"
  local job_name
  job_name="$(basename "$job_dir")"
  [ -d "$EXECUTED/$job_name" ] && return 0
  [ -f "$RECEIPTS/${job_name}-receipt.json" ] && return 0
  return 1
}

finalize_job_dir() {
  local job_dir="$1"
  local job_name
  job_name="$(basename "$job_dir")"

  mkdir -p "$EXECUTED"
  rm -rf "$EXECUTED/$job_name" 2>/dev/null || true
  mv "$job_dir" "$EXECUTED/$job_name"
  log "job moved to executed: $EXECUTED/$job_name"
}

process_job_dir() {
  local job_dir="$1"
  local manifest="${job_dir}/manifest.json"
  local sig="${job_dir}/manifest.sig"
  local payload="${job_dir}/payload.sh"
  local policy="${job_dir}/policy.json"
  local decision="${job_dir}/decision.json"
  local receipt="${RECEIPTS}/$(basename "$job_dir")-receipt.json"
  local started_at finished_at status exit_code policy_allow payload_sha manifest_sha policy_reason

  [ -f "$manifest" ] || { log "missing manifest in $job_dir"; return 0; }
  [ -f "$sig" ] || { log "missing signature in $job_dir"; return 0; }
  [ -f "$payload" ] || { log "missing payload in $job_dir"; return 0; }
  [ -f "$policy" ] || { log "missing policy in $job_dir"; return 0; }

  if job_already_processed "$job_dir"; then
    log "job already processed, moving aside: $(basename "$job_dir")"
    finalize_job_dir "$job_dir"
    return 0
  fi

  started_at="$(date -Is)"
  payload_sha="$(sha256_of "$payload")"
  manifest_sha="$(sha256_of "$manifest")"

  bash "${BASE_DIR}/security_core/verify_manifest.sh" "$manifest" || { log "manifest verify failed"; return 0; }
  bash "${BASE_DIR}/security_core/verify_signature_ed25519.sh" "$manifest" "$sig" "$ALLOWED_SIGNERS" || { log "signature verify failed"; return 0; }
  bash "${BASE_DIR}/security_core/policy_gate_v1_1.sh" "$manifest" "$policy" "$decision"

  policy_allow="false"
  policy_reason="denied"
  if grep -q '"allow": true' "$decision" 2>/dev/null; then
    policy_allow="true"
    policy_reason="allowed by local policy"
    chmod +x "$payload" 2>/dev/null || true
    if bash "$payload" >"${job_dir}/payload.stdout.log" 2>"${job_dir}/payload.stderr.log"; then
      status="success"
      exit_code=0
    else
      status="failure"
      exit_code=$?
    fi
  else
    status="denied"
    exit_code=126
    policy_reason="denied by local policy"
  fi

  finished_at="$(date -Is)"
  bash "${BASE_DIR}/security_core/write_receipt_v1_1.sh" \
    "$(basename "$job_dir")" "$status" "$policy_allow" "$policy_reason" \
    "$payload_sha" "$manifest_sha" "$AGENT_ID" "$HUB_HOST" \
    "$started_at" "$finished_at" "$exit_code" "$receipt"

  if [ -n "${RECEIPT_SIGNING_KEY:-}" ] && [ -f "${RECEIPT_SIGNING_KEY:-}" ]; then
    bash "${BASE_DIR}/security_core/sign_receipt_ed25519.sh" "$receipt" "$RECEIPT_SIGNING_KEY" || true
  fi

  bash "${BASE_DIR}/ops_hooks/attest_action.sh" "$receipt" || true
  bash "${BASE_DIR}/transport/push_receipt.sh" "$ENV_FILE" "$receipt" || log "receipt push failed"

  finalize_job_dir "$job_dir"
}

main() {
  log "Agent V1.3 started with HUB_HOST=${HUB_HOST}"
  while true; do
    pull_jobs || log "pull failed"
    find "$INBOX" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while IFS= read -r d; do
      base="$(basename "$d")"
      case "$base" in
        .*) continue ;;
      esac
      process_job_dir "$d"
    done
    sleep "$POLL"
  done
}

main "$@"
