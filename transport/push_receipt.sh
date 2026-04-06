#!/usr/bin/env bash
set -Eeuo pipefail

ENV_FILE="${1:-./transport/job.env.example}"
RECEIPT="${2:?usage: push_receipt.sh <env> <receipt.json>}"
[ -f "$ENV_FILE" ] && . "$ENV_FILE"

: "${HUB_USER:?missing HUB_USER}"
: "${HUB_HOST:?missing HUB_HOST}"
: "${HUB_PORT:?missing HUB_PORT}"
: "${HUB_RECEIPT_DIR:?missing HUB_RECEIPT_DIR}"

scp -P "$HUB_PORT" "$RECEIPT" "${HUB_USER}@${HUB_HOST}:${HUB_RECEIPT_DIR}/"
