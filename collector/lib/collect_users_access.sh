#!/usr/bin/env bash

collect_users_access() {
  local out_root="$1"
  mkdir -p "${out_root}/raw"
  {
    echo '== passwd =='
    cat /etc/passwd 2>/dev/null || true
    echo
    echo '== group =='
    cat /etc/group 2>/dev/null || true
    echo
    echo '== sudoers =='
    cat /etc/sudoers 2>/dev/null || true
    for f in /etc/sudoers.d/*; do
      [ -f "$f" ] || continue
      echo "----- $f -----"
      cat "$f" 2>/dev/null || true
    done
    echo
    echo '== ssh materials =='
    find /root /home -maxdepth 3 -type f -path '*/.ssh/*' 2>/dev/null | sed -n '1,1000p' || true
    echo
    echo '== recent logins =='
    last -a 2>/dev/null | sed -n '1,200p' || true
  } >"${out_root}/raw/users_access.txt" 2>&1 || true
}
