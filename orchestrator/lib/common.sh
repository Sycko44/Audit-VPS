#!/usr/bin/env bash
set -Eeuo pipefail

log_info() {
  printf '[INFO] %s\n' "$*" | tee -a "${LOG_DIR}/runner.log"
}

log_warn() {
  printf '[WARN] %s\n' "$*" | tee -a "${LOG_DIR}/runner.log"
}

log_error() {
  printf '[ERROR] %s\n' "$*" | tee -a "${LOG_DIR}/runner.log" >&2
}

write_json() {
  local path="$1"
  local body="$2"
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$body" > "$path"
}

sha256_of() {
  sha256sum "$1" | awk '{print $1}'
}

have() {
  command -v "$1" >/dev/null 2>&1
}
