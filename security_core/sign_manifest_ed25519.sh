#!/usr/bin/env bash
set -Eeuo pipefail

MANIFEST="${1:?usage: sign_manifest_ed25519.sh <manifest.json> <private_key>}"
PRIVKEY="${2:?usage: sign_manifest_ed25519.sh <manifest.json> <private_key>}"
NAMESPACE="${NAMESPACE:-audit-vps-job}"
SIG_OUT="${SIG_OUT:-${MANIFEST%manifest.json}manifest.sig}"

[ -f "$MANIFEST" ] || { echo "manifest missing" >&2; exit 2; }
[ -f "$PRIVKEY" ] || { echo "private key missing" >&2; exit 2; }
command -v ssh-keygen >/dev/null 2>&1 || { echo "ssh-keygen required" >&2; exit 4; }

ssh-keygen -Y sign -f "$PRIVKEY" -n "$NAMESPACE" "$MANIFEST" >/dev/null
mv "${MANIFEST}.sig" "$SIG_OUT"
echo "manifest signature written to $SIG_OUT"
