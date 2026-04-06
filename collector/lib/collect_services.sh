#!/usr/bin/env bash

collect_services() {
  local out_root="$1"
  mkdir -p "${out_root}/raw"
  {
    echo '== systemctl active =='
    systemctl list-units --type=service --state=active --no-pager 2>/dev/null || true
    echo
    echo '== failed units =='
    systemctl --failed --no-pager 2>/dev/null || true
    echo
    echo '== ps =='
    ps auxww 2>/dev/null || true
    echo
    echo '== listeners =='
    ss -tulpn 2>/dev/null || true
  } >"${out_root}/raw/services.txt" 2>&1 || true
}
