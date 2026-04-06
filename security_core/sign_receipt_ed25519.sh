#!/usr/bin/env bash
set -Eeuo pipefail

RECEIPT="${1:?usage: sign_receipt_ed25519.sh <receipt.json> <private_key>}"
PRIVKEY="${2:?usage: sign_receipt_ed25519.sh <receipt.json> <private_key>}"
NAMESPACE="${NAMESPACE:-audit-vps-receipt}"
SIG_OUT="${SIG_OUT:-${RECEIPT}.sig}"

[ -f "$RECEIPT" ] || { echo "receipt missing" >&2; exit 2; }
[ -f "$PRIVKEY" ] || { echo "private key missing" >&2; exit 2; }
command -v ssh-keygen >/dev/null 2>&1 || { echo "ssh-keygen required" >&2; exit 4; }

ssh-keygen -Y sign -f "$PRIVKEY" -n "$NAMESPACE" "$RECEIPT" >/dev/null
mv "${RECEIPT}.sig" "$SIG_OUT"
echo "receipt signature written to $SIG_OUT"
