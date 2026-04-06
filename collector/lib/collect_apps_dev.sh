#!/usr/bin/env bash

collect_apps_dev() {
  local out_root="$1"
  mkdir -p "${out_root}/raw"
  {
    echo '== runtimes =='
    python3 -V 2>/dev/null || true
    node -v 2>/dev/null || true
    php -v 2>/dev/null || true
    java -version 2>&1 || true
    go version 2>/dev/null || true
    rustc --version 2>/dev/null || true
    echo
    echo '== git repos =='
    find /root /home /var/www /srv /opt -type d -name .git 2>/dev/null | sed -n '1,1000p' || true
    echo
    echo '== app hints =='
    find /root /home /var/www /srv /opt -maxdepth 4 -type f \( -name package.json -o -name requirements.txt -o -name pyproject.toml -o -name docker-compose.yml -o -name docker-compose.yaml -o -name compose.yml -o -name compose.yaml \) 2>/dev/null | sed -n '1,2000p' || true
  } >"${out_root}/raw/apps_dev.txt" 2>&1 || true
}
