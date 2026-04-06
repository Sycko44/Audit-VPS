#!/usr/bin/env bash

collect_containers() {
  local out_root="$1"
  mkdir -p "${out_root}/raw"
  {
    echo '== docker info =='
    docker info 2>/dev/null || true
    echo
    echo '== docker ps =='
    docker ps -a 2>/dev/null || true
    echo
    echo '== docker images =='
    docker images 2>/dev/null || true
    echo
    echo '== compose files =='
    find /root /home /var/www /srv /opt -type f \( -name docker-compose.yml -o -name docker-compose.yaml -o -name compose.yml -o -name compose.yaml \) 2>/dev/null | sed -n '1,1000p' || true
    echo
    echo '== podman =='
    podman ps -a 2>/dev/null || true
  } >"${out_root}/raw/containers.txt" 2>&1 || true
}
