#!/usr/bin/env bash
set -Eeuo pipefail

SECRET_REF="${1:?usage: resolve_secret.sh <secret_ref> <decision.json>}"
DECISION="${2:?usage: resolve_secret.sh <secret_ref> <decision.json>}"

if ! grep -q '"allow": true' "$DECISION" 2>/dev/null; then
  echo "secret resolution denied by local policy" >&2
  exit 5
fi

if [ -z "${VAULT_ADDR:-}" ]; then
  echo "VAULT_ADDR not set" >&2
  exit 6
fi

echo "vault resolution placeholder for $SECRET_REF via $VAULT_ADDR"
