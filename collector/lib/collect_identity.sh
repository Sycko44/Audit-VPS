#!/usr/bin/env bash

collect_identity() {
  local out_root="$1"
  mkdir -p "${out_root}/raw"
  {
    echo "hostname=$(hostname 2>/dev/null || true)"
    echo "kernel=$(uname -a 2>/dev/null || true)"
    echo "date=$(date -Is)"
    [ -f /etc/os-release ] && cat /etc/os-release
  } >"${out_root}/raw/identity.txt" 2>&1 || true
}
