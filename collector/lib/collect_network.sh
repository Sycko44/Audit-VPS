#!/usr/bin/env bash

collect_network() {
  local out_root="$1"
  mkdir -p "${out_root}/raw"
  {
    echo '== ip addr =='
    ip addr 2>/dev/null || true
    echo
    echo '== ip route =='
    ip route 2>/dev/null || true
    echo
    echo '== ss -tulpn =='
    ss -tulpn 2>/dev/null || true
  } >"${out_root}/raw/network.txt" 2>&1 || true
}
