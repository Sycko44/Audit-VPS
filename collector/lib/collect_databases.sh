#!/usr/bin/env bash

collect_databases() {
  local out_root="$1"
  mkdir -p "${out_root}/raw"
  {
    echo '== mysql =='
    mysql --version 2>/dev/null || true
    mysqladmin variables 2>/dev/null || true
    echo
    echo '== postgres =='
    psql --version 2>/dev/null || true
    systemctl status postgresql --no-pager 2>/dev/null || true
    echo
    echo '== db config hints =='
    find /etc /var/lib -maxdepth 3 \( -path '/etc/mysql*' -o -path '/etc/postgresql*' -o -path '/var/lib/mysql*' -o -path '/var/lib/postgresql*' \) 2>/dev/null | sed -n '1,1000p' || true
  } >"${out_root}/raw/databases.txt" 2>&1 || true
}
