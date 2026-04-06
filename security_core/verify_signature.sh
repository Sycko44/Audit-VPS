#!/usr/bin/env bash
set -Eeuo pipefail

MANIFEST="${1:?usage: verify_signature.sh <manifest.json> <manifest.sig> <public_key>}"
SIG="${2:?usage: verify_signature.sh <manifest.json> <manifest.sig> <public_key>}"
PUB="${3:?usage: verify_signature.sh <manifest.json> <manifest.sig> <public_key>}"

[ -f "$MANIFEST" ] || { echo "manifest missing" >&2; exit 2; }
[ -f "$SIG" ] || { echo "signature missing" >&2; exit 2; }
[ -f "$PUB" ] || { echo "public key missing" >&2; exit 2; }

echo "signature verification placeholder"
echo "manifest=$MANIFEST"
echo "signature=$SIG"
echo "public_key=$PUB"
