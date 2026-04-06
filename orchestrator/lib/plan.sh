#!/usr/bin/env bash
set -Eeuo pipefail

build_plan() {
  local plan_file="${ARTIFACT_DIR}/plan.txt"
  : > "$plan_file"
  printf 'step:check_pulseo\n' >> "$plan_file"
  printf 'step:verify_repo_layout\n' >> "$plan_file"
  printf 'step:verify_signing_materials\n' >> "$plan_file"
  printf 'step:prepare_job_bundle_or_agent\n' >> "$plan_file"
  printf 'step:verify_state\n' >> "$plan_file"
  log_info "plan written to ${plan_file}"
}
