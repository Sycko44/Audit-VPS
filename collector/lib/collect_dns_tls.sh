#!/usr/bin/env bash

collect_dns_tls() {
  local out_root="$1"
  mkdir -p "${out_root}/raw"
  {
    echo '== resolv.conf =='
    cat /etc/resolv.conf 2>/dev/null || true
    echo
    echo '== hostname =='
    hostname 2>/dev/null || true
    hostname -f 2>/dev/null || true
    echo
    echo '== resolvectl/systemd-resolve =='
    resolvectl status 2>/dev/null || systemd-resolve --status 2>/dev/null || true
    echo
    echo '== nginx server_name =='
    grep -R "server_name" /etc/nginx 2>/dev/null || true
    echo
    echo '== apache virtualhost =='
    grep -R "ServerName\|ServerAlias" /etc/apache2 /etc/httpd 2>/dev/null || true
    echo
    echo '== cert files =='
    find /etc/letsencrypt /var/lib/acme -type f 2>/dev/null | sed -n '1,1000p' || true
  } >"${out_root}/raw/dns_tls.txt" 2>&1 || true
}
