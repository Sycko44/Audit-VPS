#!/usr/bin/env bash
set -Eeuo pipefail

USER_NAME="${1:-admin}"
HTPASSWD_FILE="${2:-/etc/nginx/.htpasswd_pulseo_admin}"

if ! command -v htpasswd >/dev/null 2>&1; then
  echo "htpasswd command is required (apache2-utils)" >&2
  exit 2
fi

sudo mkdir -p "$(dirname "$HTPASSWD_FILE")"
sudo htpasswd -c "$HTPASSWD_FILE" "$USER_NAME"
sudo chmod 640 "$HTPASSWD_FILE"
echo "htpasswd created at $HTPASSWD_FILE for user $USER_NAME"
