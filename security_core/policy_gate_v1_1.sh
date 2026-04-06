#!/usr/bin/env bash
set -Eeuo pipefail

MANIFEST="${1:?usage: policy_gate_v1_1.sh <manifest.json> <policy.json> <decision.json>}"
POLICY="${2:?usage: policy_gate_v1_1.sh <manifest.json> <policy.json> <decision.json>}"
DECISION_OUT="${3:?usage: policy_gate_v1_1.sh <manifest.json> <policy.json> <decision.json>}"

mkdir -p "$(dirname "$DECISION_OUT")"

python3 - "$MANIFEST" "$POLICY" "$DECISION_OUT" <<'PY'
import json, sys
manifest_path, policy_path, out_path = sys.argv[1:4]
with open(manifest_path, 'r', encoding='utf-8') as f:
    manifest = json.load(f)
with open(policy_path, 'r', encoding='utf-8') as f:
    policy = json.load(f)

allow = False
reason = 'default deny'
key_ok = manifest.get('signing_key_id') in policy.get('trusted_signing_keys', [])
kind_ok = manifest.get('allowed_payload_kind') in policy.get('allowed_payload_kinds', [])
scope_ok = manifest.get('target_scope') in policy.get('allowed_target_scopes', [])
secret_refs = manifest.get('secret_refs', []) or []
secrets_ok = (not secret_refs) or bool(policy.get('allow_secret_resolution', False))

if policy.get('default') == 'deny':
    if key_ok and kind_ok and scope_ok and secrets_ok:
        allow = True
        reason = 'trusted key, payload kind, target scope and secret policy matched'
    else:
        parts = []
        if not key_ok:
            parts.append('untrusted signing key')
        if not kind_ok:
            parts.append('payload kind not allowed')
        if not scope_ok:
            parts.append('target scope not allowed')
        if not secrets_ok:
            parts.append('secret resolution not allowed')
        reason = '; '.join(parts) if parts else 'default deny'
else:
    allow = True
    reason = 'policy default allow'

with open(out_path, 'w', encoding='utf-8') as f:
    json.dump({
        'allow': allow,
        'reason': reason,
        'manifest': manifest_path,
        'policy': policy_path,
        'signing_key_id': manifest.get('signing_key_id'),
        'payload_kind': manifest.get('allowed_payload_kind'),
        'target_scope': manifest.get('target_scope'),
        'secret_ref_count': len(secret_refs),
    }, f, indent=2)
PY

echo "policy decision written to $DECISION_OUT"
