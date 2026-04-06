#!/usr/bin/env bash
set -Eeuo pipefail

verify_state() {
  local verify_log="${ARTIFACT_DIR}/verify.txt"
  local ok=0
  : > "$verify_log"

  for path in \
    "${ROOT_DIR}/security_core/verify_manifest.sh" \
    "${ROOT_DIR}/security_core/verify_signature_ed25519.sh" \
    "${ROOT_DIR}/security_core/policy_gate_v1_1.sh" \
    "${ROOT_DIR}/integration/termux/agent_termux_v1_2.sh" \
    "${ROOT_DIR}/transport/build_job_bundle.sh"; do
    if [ -f "$path" ]; then
      printf 'ok:%s\n' "$path" >> "$verify_log"
    else
      printf 'missing:%s\n' "$path" >> "$verify_log"
      ok=1
    fi
  done

  if grep -q '^missing:' "$verify_log"; then
    log_warn "verification found missing components"
    return 1
  fi

  log_info "verification passed"
  return 0
}
