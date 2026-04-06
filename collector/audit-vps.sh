#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

MODE="${1:-quick}"
TS="$(date +%Y%m%d_%H%M%S)"
HOST="$(hostname 2>/dev/null || echo unknown)"
OUT_ROOT="${PWD}/output/${HOST}/${TS}"

mkdir -p "${OUT_ROOT}"/{raw,maps,manifests,previews,summary,logs}

# shellcheck source=/dev/null
source "${LIB_DIR}/common.sh"

log_info "Audit-VPS collector started"
log_info "Mode=${MODE} Host=${HOST} Out=${OUT_ROOT}"

MODULES_QUICK=(
  collect_identity
  collect_storage
  collect_network
  collect_users_access
  collect_services
)

MODULES_DEEP=(
  collect_identity
  collect_storage
  collect_network
  collect_dns_tls
  collect_users_access
  collect_persistence
  collect_services
  collect_apps_dev
  collect_containers
  collect_databases
  collect_files
  collect_findings
)

MODULES_FORENSIC=(
  collect_identity
  collect_storage
  collect_network
  collect_dns_tls
  collect_users_access
  collect_persistence
  collect_services
  collect_apps_dev
  collect_containers
  collect_databases
  collect_files
  collect_findings
)

load_module() {
  local name="$1"
  # shellcheck source=/dev/null
  source "${LIB_DIR}/${name}.sh"
}

run_mode() {
  local mode="$1"
  local modules=()

  case "$mode" in
    quick) modules=("${MODULES_QUICK[@]}") ;;
    deep) modules=("${MODULES_DEEP[@]}") ;;
    forensic) modules=("${MODULES_FORENSIC[@]}") ;;
    *) log_error "Unknown mode: ${mode}"; exit 1 ;;
  esac

  for mod in "${modules[@]}"; do
    load_module "$mod"
    run_module "$mod" "$OUT_ROOT"
  done
}

run_mode "$MODE"
write_hash_manifest "$OUT_ROOT"
write_stub_summary "$OUT_ROOT" "$MODE" "$HOST"

log_info "Audit-VPS collector finished"
