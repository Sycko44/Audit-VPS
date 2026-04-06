#!/usr/bin/env bash
set -Eeuo pipefail

PUBKEY="${1:?usage: build_allowed_signers.sh <public_key.pub> <identity> <out_file>}"
IDENTITY="${2:?usage: build_allowed_signers.sh <public_key.pub> <identity> <out_file>}"
OUT="${3:?usage: build_allowed_signers.sh <public_key.pub> <identity> <out_file>}"

[ -f "$PUBKEY" ] || { echo "public key missing" >&2; exit 2; }
mkdir -p "$(dirname "$OUT")"

KEY_CONTENT="$(cat "$PUBKEY")"
printf '%s %s\n' "$IDENTITY" "$KEY_CONTENT" > "$OUT"
echo "allowed signers written to $OUT"
