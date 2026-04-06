#!/usr/bin/env bash
set -Eeuo pipefail

MANIFEST="${1:?usage: verify_manifest.sh <manifest.json>}"
[ -f "$MANIFEST" ] || { echo "manifest missing: $MANIFEST" >&2; exit 2; }

for key in '"job_id"' '"payload"' '"sha256"' '"signing_key_id"' '"created_at"' '"policy_ref"'; do
  grep -q "$key" "$MANIFEST" || { echo "manifest missing key: $key" >&2; exit 3; }
done

echo "manifest ok: $MANIFEST"
