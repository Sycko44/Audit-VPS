#!/usr/bin/env bash

collect_persistence() {
  local out_root="$1"
  mkdir -p "${out_root}/raw"
  {
    echo '== systemd services =='
    systemctl list-unit-files --type=service --no-pager 2>/dev/null || true
    echo
    echo '== systemd timers =='
    systemctl list-timers --all --no-pager 2>/dev/null || true
    echo
    echo '== crontab system =='
    cat /etc/crontab 2>/dev/null || true
    echo
    echo '== cron directories =='
    ls -la /etc/cron.d /etc/cron.daily /etc/cron.weekly /etc/cron.monthly 2>/dev/null || true
    echo
    echo '== user crons =='
    for d in /var/spool/cron /var/spool/cron/crontabs; do
      [ -d "$d" ] || continue
      echo "----- $d -----"
      ls -la "$d" 2>/dev/null || true
      for f in "$d"/*; do
        [ -f "$f" ] || continue
        echo "----- $f -----"
        cat "$f" 2>/dev/null || true
      done
    done
  } >"${out_root}/raw/persistence.txt" 2>&1 || true
}
