#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="${ROOT_DIR}/orchestrator/lib"
MODE="${1:-plan}"
RUN_ID="${RUN_ID:-run-$(date +%Y%m%d_%H%M%S)}"
STATE_DIR="${STATE_DIR:-${ROOT_DIR}/.state/${RUN_ID}}"
LOG_DIR="${STATE_DIR}/logs"
ARTIFACT_DIR="${STATE_DIR}/artifacts"
MAX_REPAIR_ATTEMPTS="${MAX_REPAIR_ATTEMPTS:-2}"

mkdir -p "$LOG_DIR" "$ARTIFACT_DIR"

# shellcheck source=/dev/null
source "${LIB_DIR}/common.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/precheck.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/plan.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/apply.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/repair.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/verify.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/receipt.sh"

export ROOT_DIR LIB_DIR MODE RUN_ID STATE_DIR LOG_DIR ARTIFACT_DIR MAX_REPAIR_ATTEMPTS

main() {
  log_info "runner start mode=${MODE} run_id=${RUN_ID}"
  detect_environment
  run_prechecks
  build_plan

  case "$MODE" in
    inspect|plan)
      log_info "plan-only mode completed"
      write_receipt_final "planned" 0
      ;;
    apply|deploy)
      apply_plan
      if verify_state; then
        write_receipt_final "success" 0
      else
        log_warn "initial verification failed; entering repair loop"
        attempt_repairs
      fi
      ;;
    repair)
      attempt_repairs
      ;;
    *)
      log_error "unknown mode: $MODE"
      write_receipt_final "error" 2
      exit 2
      ;;
  esac

  log_info "runner finished"
}

attempt_repairs() {
  local attempt=1
  while [ "$attempt" -le "$MAX_REPAIR_ATTEMPTS" ]; do
    log_info "repair attempt ${attempt}/${MAX_REPAIR_ATTEMPTS}"
    run_repair "$attempt"
    if verify_state; then
      write_receipt_final "repaired" 0
      return 0
    fi
    attempt=$((attempt+1))
  done
  log_error "repairs exhausted"
  write_receipt_final "failed" 1
  return 1
}

main "$@"
