#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="${1:-$ROOT/.tmp-test-allow}"
rm -rf "$TMP"
mkdir -p "$TMP/keys" "$TMP/out"

bash "$ROOT/security_core/generate_ed25519_keys.sh" "$TMP/keys" trustplane_ed25519 trustplane-signer
bash "$ROOT/security_core/build_allowed_signers.sh" "$TMP/keys/trustplane_ed25519.pub" trustplane-signer "$TMP/keys/allowed_signers"

cat > "$TMP/payload.sh" <<'EOF'
#!/usr/bin/env bash
echo allow-test
EOF
chmod +x "$TMP/payload.sh"

SIGNING_KEY_PATH="$TMP/keys/trustplane_ed25519" \
PAYLOAD_KIND="audit" \
TARGET_SCOPE="termux-agent" \
RECEIPTS_TO="pulseo.me:/tmp/receipts" \
bash "$ROOT/transport/build_job_bundle.sh" job-allow-001 "$TMP/payload.sh" trustplane-ed25519-main "$TMP/out"

bash "$ROOT/security_core/verify_manifest.sh" "$TMP/out/job-allow-001/manifest.json"
bash "$ROOT/security_core/verify_signature_ed25519.sh" "$TMP/out/job-allow-001/manifest.json" "$TMP/out/job-allow-001/manifest.sig" "$TMP/keys/allowed_signers"
bash "$ROOT/security_core/policy_gate_v1_1.sh" "$TMP/out/job-allow-001/manifest.json" "$ROOT/integration/policies/local_policy_house.json" "$TMP/out/job-allow-001/decision.json"

grep -q '"allow": true' "$TMP/out/job-allow-001/decision.json"
echo "allow flow ok"
