#!/usr/bin/env bash
set -Eeuo pipefail

MANIFEST="${1:?usage: policy_gate.sh <manifest.json> <decision.json>}"
DECISION_OUT="${2:?usage: policy_gate.sh <manifest.json> <decision.json>}"

mkdir -p "$(dirname "$DECISION_OUT")"
cat > "$DECISION_OUT" <<EOF
{
  "allow": false,
  "reason": "default deny until local trust policy is connected",
  "manifest": "$MANIFEST"
}
EOF

echo "policy decision written to $DECISION_OUT"
