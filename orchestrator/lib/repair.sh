#!/usr/bin/env bash
set -Eeuo pipefail

run_repair() {
  local attempt="$1"
  local repair_log="${ARTIFACT_DIR}/repair-attempt-${attempt}.txt"
  : > "$repair_log"

  if [ ! -f "${ROOT_DIR}/transport/job.env.example" ] && [ -f "${ROOT_DIR}/transport/job.env.example" ]; then
    printf 'noop:job-env\n' >> "$repair_log"
  fi

  if [ ! -f "${ROOT_DIR}/integration/examples/allowed_signers.example" ]; then
    printf 'missing:allowed_signers_example\n' >> "$repair_log"
  else
    printf 'ok:allowed_signers_example\n' >> "$repair_log"
  fi

  if ! command -v ssh-keygen >/dev/null 2>&1; then
    printf 'missing:ssh-keygen\n' >> "$repair_log"
  else
    printf 'ok:ssh-keygen\n' >> "$repair_log"
  fi

  log_info "repair attempt ${attempt} completed"
}
