#!/usr/bin/env bash
set -Eeuo pipefail

JOB_ID="${1:?usage: build_job_bundle.sh <job_id> <payload.sh> <signing_key_id> <out_dir>}"
PAYLOAD="${2:?usage: build_job_bundle.sh <job_id> <payload.sh> <signing_key_id> <out_dir>}"
SIGNING_KEY_ID="${3:?usage: build_job_bundle.sh <job_id> <payload.sh> <signing_key_id> <out_dir>}"
OUT_DIR="${4:?usage: build_job_bundle.sh <job_id> <payload.sh> <signing_key_id> <out_dir>}"
POLICY_ID="${POLICY_ID:-default-local-deny}"
PAYLOAD_KIND="${PAYLOAD_KIND:-audit}"
TARGET_SCOPE="${TARGET_SCOPE:-termux-agent}"
RECEIPTS_TO="${RECEIPTS_TO:-pulseo.me:/home/USER_OVH/agent_hub/receipts}"

mkdir -p "$OUT_DIR/$JOB_ID"
cp "$PAYLOAD" "$OUT_DIR/$JOB_ID/payload.sh"
PAYLOAD_SHA="$(sha256sum "$OUT_DIR/$JOB_ID/payload.sh" | awk '{print $1}')"

cat > "$OUT_DIR/$JOB_ID/manifest.json" <<EOF
{
  "job_id": "$JOB_ID",
  "payload": "payload.sh",
  "sha256": "$PAYLOAD_SHA",
  "signing_key_id": "$SIGNING_KEY_ID",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "policy_ref": "$POLICY_ID",
  "allowed_payload_kind": "$PAYLOAD_KIND",
  "target_scope": "$TARGET_SCOPE",
  "secret_refs": [],
  "receipts_to": "$RECEIPTS_TO",
  "attestation_required": true
}
EOF

cat > "$OUT_DIR/$JOB_ID/policy.json" <<EOF
{
  "policy_id": "$POLICY_ID",
  "default": "deny",
  "trusted_signing_keys": ["$SIGNING_KEY_ID"],
  "allowed_payload_kinds": ["$PAYLOAD_KIND"],
  "allowed_target_scopes": ["$TARGET_SCOPE"],
  "allow_secret_resolution": false
}
EOF

if [ -n "${SIGNING_KEY_PATH:-}" ] && [ -f "${SIGNING_KEY_PATH:-}" ] && command -v ssh-keygen >/dev/null 2>&1; then
  ssh-keygen -Y sign -f "$SIGNING_KEY_PATH" -n audit-vps-job "$OUT_DIR/$JOB_ID/manifest.json" >/dev/null
  mv "$OUT_DIR/$JOB_ID/manifest.json.sig" "$OUT_DIR/$JOB_ID/manifest.sig"
else
  echo "REPLACE_WITH_REAL_SIGNATURE" > "$OUT_DIR/$JOB_ID/manifest.sig"
fi

echo "job bundle built at $OUT_DIR/$JOB_ID"
