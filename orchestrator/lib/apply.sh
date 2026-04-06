#!/usr/bin/env bash
set -Eeuo pipefail

apply_plan() {
  local apply_log="${ARTIFACT_DIR}/apply.txt"
  : > "$apply_log"

  if [ -x "${ROOT_DIR}/transport/check_pulseo_me.sh" ]; then
    bash "${ROOT_DIR}/transport/check_pulseo_me.sh" pulseo.me 22 >> "$apply_log" 2>&1 || true
    log_info "pulseo.me check executed"
  fi

  if [ -f "${ROOT_DIR}/integration/policies/local_policy_house.json" ]; then
    printf 'ok:policy-house\n' >> "$apply_log"
  else
    printf 'missing:policy-house\n' >> "$apply_log"
  fi

  if [ -f "${ROOT_DIR}/transport/job.env.example" ]; then
    printf 'ok:job-env\n' >> "$apply_log"
  else
    printf 'missing:job-env\n' >> "$apply_log"
  fi

  log_info "apply stage completed"
}
