#!/usr/bin/env bash
set -Eeuo pipefail

ENV_FILE="${1:-./transport/job.env.example}"
[ -f "$ENV_FILE" ] && . "$ENV_FILE"

: "${HUB_USER:?missing HUB_USER}"
: "${HUB_HOST:?missing HUB_HOST}"
: "${HUB_PORT:?missing HUB_PORT}"
: "${HUB_JOB_DIR:?missing HUB_JOB_DIR}"

DEST="${2:-./inbox}"
mkdir -p "$DEST"

scp -P "$HUB_PORT" -r "${HUB_USER}@${HUB_HOST}:${HUB_JOB_DIR}" "$DEST/" 
