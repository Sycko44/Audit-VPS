#!/usr/bin/env bash
set -Eeuo pipefail

MANIFEST="${1:?usage: verify_signature_ed25519.sh <manifest.json> <manifest.sig> <allowed_signers>}"
SIG="${2:?usage: verify_signature_ed25519.sh <manifest.json> <manifest.sig> <allowed_signers>}"
ALLOWED_SIGNERS="${3:?usage: verify_signature_ed25519.sh <manifest.json> <manifest.sig> <allowed_signers>}"
NAMESPACE="${NAMESPACE:-audit-vps-job}"

[ -f "$MANIFEST" ] || { echo "manifest missing" >&2; exit 2; }
[ -f "$SIG" ] || { echo "signature missing" >&2; exit 2; }
[ -f "$ALLOWED_SIGNERS" ] || { echo "allowed signers file missing" >&2; exit 2; }

if ! command -v ssh-keygen >/dev/null 2>&1; then
  echo "ssh-keygen is required for Ed25519 verification" >&2
  exit 4
fi

ssh-keygen -Y verify \
  -f "$ALLOWED_SIGNERS" \
  -I trustplane-signer \
  -n "$NAMESPACE" \
  -s "$SIG" < "$MANIFEST"
