#!/usr/bin/env bash

collect_findings() {
  local out_root="$1"
  mkdir -p "${out_root}/raw"
  {
    echo '== world writable files =='
    find / -xdev -type f -perm -0002 2>/dev/null | sed -n '1,1000p' || true
    echo
    echo '== suid sgid =='
    find / -xdev \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null | sed -n '1,1000p' || true
    echo
    echo '== broken symlinks =='
    find / -xtype l 2>/dev/null | sed -n '1,1000p' || true
    echo
    echo '== recent sensitive changes =='
    find /etc /root /home /var/www /srv /opt -type f -mtime -7 2>/dev/null | sed -n '1,1000p' || true
  } >"${out_root}/raw/findings_first_pass.txt" 2>&1 || true
}
