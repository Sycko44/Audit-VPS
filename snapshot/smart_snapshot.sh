#!/usr/bin/env bash
set -Eeuo pipefail

SNAP_ROOT="${1:-./snapshots}"
LABEL="${2:-smart-$(date +%Y%m%d_%H%M%S)}"
SRC_DIR="${3:-.}"
OUT_DIR="${SNAP_ROOT}/${LABEL}"

mkdir -p "$OUT_DIR"

find "$SRC_DIR" -type f \
  ! -path '*/.git/*' \
  ! -path '*/snapshots/*' \
  -print0 | while IFS= read -r -d '' f; do
    rel="${f#${SRC_DIR}/}"
    mkdir -p "${OUT_DIR}/$(dirname "$rel")"
    cp "$f" "${OUT_DIR}/$rel"
  done

find "$OUT_DIR" -type f -print0 | while IFS= read -r -d '' f; do
  sha256sum "$f"
done > "$OUT_DIR/hash_manifest.txt"

cat > "$OUT_DIR/snapshot_meta.json" <<EOF
{
  "label": "$LABEL",
  "created_at": "$(date -Is)",
  "source": "$SRC_DIR",
  "type": "intelligent-foundation-snapshot",
  "scope": [
    "docs",
    "collector",
    "analyzer",
    "security_core",
    "transport",
    "integration",
    "vault_adapter",
    "ops_hooks",
    "schemas"
  ],
  "notes": "foundation snapshot taken after steps 1 to 9 before future snapshot policy redefinition"
}
EOF

echo "smart snapshot created at $OUT_DIR"
