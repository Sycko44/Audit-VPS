#!/usr/bin/env bash
set -Eeuo pipefail

JOB_ID="${1:?usage: write_receipt.sh <job_id> <status> <receipt.json>}"
STATUS="${2:?usage: write_receipt.sh <job_id> <status> <receipt.json>}"
OUT="${3:?usage: write_receipt.sh <job_id> <status> <receipt.json>}"

mkdir -p "$(dirname "$OUT")"
cat > "$OUT" <<EOF
{
  "job_id": "$JOB_ID",
  "status": "$STATUS",
  "written_at": "$(date -Is)",
  "attested": false,
  "signed": false
}
EOF

echo "receipt written to $OUT"
