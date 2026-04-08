#!/usr/bin/env bash
set -Eeuo pipefail

ENV_FILE="${1:-./transport/job.env.local}"
[ -f "$ENV_FILE" ] && . "$ENV_FILE"

: "${HUB_USER:?missing HUB_USER}"
: "${HUB_HOST:?missing HUB_HOST}"
: "${HUB_PORT:?missing HUB_PORT}"
: "${HUB_JOB_DIR:?missing HUB_JOB_DIR}"

DEST="${2:-./inbox}"
mkdir -p "$DEST"

TMP_PULL="${DEST}/.pull_tmp"
rm -rf "$TMP_PULL"
mkdir -p "$TMP_PULL"

scp -P "$HUB_PORT" -r "${HUB_USER}@${HUB_HOST}:${HUB_JOB_DIR}/." "$TMP_PULL/"

shopt -s nullglob dotglob
for item in "$TMP_PULL"/*; do
  base="$(basename "$item")"
  if [ -e "$DEST/$base" ]; then
    echo "[pull] skip existing: $DEST/$base" >&2
    continue
  fi
  mv "$item" "$DEST/$base"
done
shopt -u nullglob dotglob

rmdir "$TMP_PULL" 2>/dev/null || true
