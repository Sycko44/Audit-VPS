#!/usr/bin/env bash
set -Eeuo pipefail

log_info() {
  printf '[INFO] %s\n' "$*" | tee -a "${OUT_ROOT:-.}/logs/run.log"
}

log_warn() {
  printf '[WARN] %s\n' "$*" | tee -a "${OUT_ROOT:-.}/logs/run.log"
}

log_error() {
  printf '[ERROR] %s\n' "$*" | tee -a "${OUT_ROOT:-.}/logs/run.log" >&2
}

run_module() {
  local mod="$1"
  local out_root="$2"
  log_info "Running module ${mod}"
  if declare -F "${mod}" >/dev/null 2>&1; then
    "${mod}" "$out_root" || log_warn "Module ${mod} failed"
  else
    log_warn "Module function ${mod} not found"
  fi
}

write_hash_manifest() {
  local out_root="$1"
  local manifest="${out_root}/manifests/hash_manifest.txt"
  : >"$manifest"
  find "$out_root" -type f ! -path "*/hash_manifest.txt" -print0 2>/dev/null \
    | while IFS= read -r -d '' f; do
        sha256sum "$f" >>"$manifest" 2>/dev/null || true
      done
}

write_stub_summary() {
  local out_root="$1"
  local mode="$2"
  local host="$3"
  cat >"${out_root}/summary/summary.md" <<EOF
# Audit-VPS Summary

- Host: ${host}
- Mode: ${mode}
- Generated: $(date -Is)

This is an initial scaffold summary. The next implementation steps should replace this with synthesized findings, maps and remediation candidates.
EOF
}

write_placeholder() {
  local target="$1"
  local title="$2"
  mkdir -p "$(dirname "$target")"
  cat >"$target" <<EOF
# ${title}

Generated placeholder.
EOF
}
