#!/usr/bin/env bash
set -Eeuo pipefail

JOB_ID="${1:?usage: write_receipt_v1_1.sh <job_id> <status> <policy_allow> <policy_reason> <payload_sha256> <manifest_sha256> <agent_id> <hub_host> <started_at> <finished_at> <exit_code> <out.json>}"
STATUS="${2:?usage: write_receipt_v1_1.sh <job_id> <status> <policy_allow> <policy_reason> <payload_sha256> <manifest_sha256> <agent_id> <hub_host> <started_at> <finished_at> <exit_code> <out.json>}"
POLICY_ALLOW="${3:?usage: write_receipt_v1_1.sh <job_id> <status> <policy_allow> <policy_reason> <payload_sha256> <manifest_sha256> <agent_id> <hub_host> <started_at> <finished_at> <exit_code> <out.json>}"
POLICY_REASON="${4:?usage: write_receipt_v1_1.sh <job_id> <status> <policy_allow> <policy_reason> <payload_sha256> <manifest_sha256> <agent_id> <hub_host> <started_at> <finished_at> <exit_code> <out.json>}"
PAYLOAD_SHA="${5:?usage: write_receipt_v1_1.sh <job_id> <status> <policy_allow> <policy_reason> <payload_sha256> <manifest_sha256> <agent_id> <hub_host> <started_at> <finished_at> <exit_code> <out.json>}"
MANIFEST_SHA="${6:?usage: write_receipt_v1_1.sh <job_id> <status> <policy_allow> <policy_reason> <payload_sha256> <manifest_sha256> <agent_id> <hub_host> <started_at> <finished_at> <exit_code> <out.json>}"
AGENT_ID="${7:?usage: write_receipt_v1_1.sh <job_id> <status> <policy_allow> <policy_reason> <payload_sha256> <manifest_sha256> <agent_id> <hub_host> <started_at> <finished_at> <exit_code> <out.json>}"
HUB_HOST="${8:?usage: write_receipt_v1_1.sh <job_id> <status> <policy_allow> <policy_reason> <payload_sha256> <manifest_sha256> <agent_id> <hub_host> <started_at> <finished_at> <exit_code> <out.json>}"
STARTED_AT="${9:?usage: write_receipt_v1_1.sh <job_id> <status> <policy_allow> <policy_reason> <payload_sha256> <manifest_sha256> <agent_id> <hub_host> <started_at> <finished_at> <exit_code> <out.json>}"
FINISHED_AT="${10:?usage: write_receipt_v1_1.sh <job_id> <status> <policy_allow> <policy_reason> <payload_sha256> <manifest_sha256> <agent_id> <hub_host> <started_at> <finished_at> <exit_code> <out.json>}"
EXIT_CODE="${11:?usage: write_receipt_v1_1.sh <job_id> <status> <policy_allow> <policy_reason> <payload_sha256> <manifest_sha256> <agent_id> <hub_host> <started_at> <finished_at> <exit_code> <out.json>}"
OUT="${12:?usage: write_receipt_v1_1.sh <job_id> <status> <policy_allow> <policy_reason> <payload_sha256> <manifest_sha256> <agent_id> <hub_host> <started_at> <finished_at> <exit_code> <out.json>}"

mkdir -p "$(dirname "$OUT")"
cat > "$OUT" <<EOF
{
  "job_id": "$JOB_ID",
  "status": "$STATUS",
  "policy_allow": $POLICY_ALLOW,
  "policy_reason": "$POLICY_REASON",
  "payload_sha256": "$PAYLOAD_SHA",
  "manifest_sha256": "$MANIFEST_SHA",
  "agent_id": "$AGENT_ID",
  "hub_host": "$HUB_HOST",
  "started_at": "$STARTED_AT",
  "finished_at": "$FINISHED_AT",
  "exit_code": $EXIT_CODE,
  "attested": false,
  "signed": false,
  "secret_events": []
}
EOF

echo "receipt written to $OUT"
