#!/usr/bin/env bash
set -Eeuo pipefail

detect_environment() {
  local os kernel host user
  os="unknown"
  if [ -f /etc/os-release ]; then
    os="$(. /etc/os-release && echo "${ID:-unknown}")"
  fi
  kernel="$(uname -r 2>/dev/null || echo unknown)"
  host="$(hostname 2>/dev/null || echo unknown)"
  user="$(id -un 2>/dev/null || echo unknown)"
  printf 'os=%s\nkernel=%s\nhost=%s\nuser=%s\n' "$os" "$kernel" "$host" "$user" > "${ARTIFACT_DIR}/environment.txt"
  log_info "environment detected os=${os} host=${host} user=${user}"
}

run_prechecks() {
  local failures=0
  : > "${ARTIFACT_DIR}/prechecks.txt"
  for cmd in bash python3 ssh-keygen sha256sum; do
    if have "$cmd"; then
      printf 'ok:%s\n' "$cmd" >> "${ARTIFACT_DIR}/prechecks.txt"
    else
      printf 'missing:%s\n' "$cmd" >> "${ARTIFACT_DIR}/prechecks.txt"
      failures=$((failures+1))
    fi
  done
  if [ ! -w "$STATE_DIR" ]; then
    printf 'missing:writable-state-dir\n' >> "${ARTIFACT_DIR}/prechecks.txt"
    failures=$((failures+1))
  fi
  if [ "$failures" -gt 0 ]; then
    log_warn "prechecks found ${failures} issue(s)"
  else
    log_info "prechecks passed"
  fi
}
