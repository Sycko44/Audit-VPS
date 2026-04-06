#!/usr/bin/env bash
set -Eeuo pipefail

HOST="${1:-pulseo.me}"
PORT="${2:-22}"

printf '== DNS ==\n'
getent hosts "$HOST" || nslookup "$HOST" 2>/dev/null || true
printf '\n== TCP ==\n'
if command -v nc >/dev/null 2>&1; then
  nc -vz "$HOST" "$PORT" || true
else
  echo "nc not available"
fi
printf '\n== HTTPS HEAD ==\n'
if command -v curl >/dev/null 2>&1; then
  curl -kI --max-time 5 "https://$HOST" 2>/dev/null || true
else
  echo "curl not available"
fi
