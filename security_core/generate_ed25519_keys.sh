#!/usr/bin/env bash
set -Eeuo pipefail

KEY_DIR="${1:-./keys}"
KEY_NAME="${2:-trustplane_ed25519}"
COMMENT="${3:-trustplane-signer}"

mkdir -p "$KEY_DIR"
PRIV="$KEY_DIR/$KEY_NAME"
PUB="$KEY_DIR/$KEY_NAME.pub"

if [ -f "$PRIV" ] || [ -f "$PUB" ]; then
  echo "key already exists: $PRIV" >&2
  exit 2
fi

ssh-keygen -t ed25519 -N "" -C "$COMMENT" -f "$PRIV"
echo "private=$PRIV"
echo "public=$PUB"
