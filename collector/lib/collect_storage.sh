#!/usr/bin/env bash

collect_storage() {
  local out_root="$1"
  mkdir -p "${out_root}/raw"
  {
    echo '== df -hT =='
    df -hT 2>/dev/null || true
    echo
    echo '== lsblk =='
    lsblk -a 2>/dev/null || true
  } >"${out_root}/raw/storage.txt" 2>&1 || true
}
