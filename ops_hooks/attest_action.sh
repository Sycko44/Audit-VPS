#!/usr/bin/env bash
set -Eeuo pipefail

RECEIPT="${1:?usage: attest_action.sh <receipt.json>}"
ATTEST_OUT="${ATTEST_OUT:-${RECEIPT%.json}.attestation.json}"

mkdir -p "$(dirname "$ATTEST_OUT")"
cat > "$ATTEST_OUT" <<EOF
{
  "source_receipt": "$RECEIPT",
  "attested_at": "$(date -Is)",
  "ops_status": "recorded",
  "notes": "OPS hook placeholder recorded this event"
}
EOF

echo "attestation written to $ATTEST_OUT"
