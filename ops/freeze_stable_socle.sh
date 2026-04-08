#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$HOME/Audit-VPS"
TS="$(date +%Y%m%d_%H%M%S)"
LABEL="socle-stable-${TS}"
OUT_DIR="$REPO_DIR/frozen_states/$LABEL"

mkdir -p "$OUT_DIR"

info() { printf '[INFO] %s\n' "$*"; }

cd "$REPO_DIR"

info "1) Snapshot intelligent du repo"
bash snapshot/smart_snapshot.sh "$REPO_DIR/frozen_states" "$LABEL" "$REPO_DIR"

info "2) Export etat systemd"
systemctl status audit-vps-agent.service --no-pager > "$OUT_DIR/systemd_status.txt" 2>&1 || true
systemctl cat audit-vps-agent.service > "$OUT_DIR/systemd_unit.txt" 2>&1 || true

info "3) Export etat agent"
find "$HOME/.audit-vps-agent/inbox" -maxdepth 3 | sort > "$OUT_DIR/agent_inbox.txt" 2>&1 || true
find "$HOME/.audit-vps-agent/executed" -maxdepth 5 | sort > "$OUT_DIR/agent_executed.txt" 2>&1 || true
find "$HOME/.audit-vps-agent/receipts" -maxdepth 5 | sort > "$OUT_DIR/agent_receipts.txt" 2>&1 || true
journalctl -u audit-vps-agent.service -n 200 --no-pager > "$OUT_DIR/agent_journal.txt" 2>&1 || true

info "4) Export config transport et securite"
cp -f "$REPO_DIR/transport/job.env.local" "$OUT_DIR/" 2>/dev/null || true
cp -f "$REPO_DIR/keys/allowed_signers" "$OUT_DIR/" 2>/dev/null || true
cp -f "$REPO_DIR/integration/policies/local_policy_house.json" "$OUT_DIR/" 2>/dev/null || true

info "5) Export etat web"
sudo nginx -t > "$OUT_DIR/nginx_test.txt" 2>&1 || true
sudo cp /etc/nginx/sites-available/pulseo.me "$OUT_DIR/pulseo.me.nginx.conf" 2>/dev/null || true
curl -I https://pulseo.me > "$OUT_DIR/pulseo_public_head.txt" 2>&1 || true
curl -I https://admin.pulseo.me > "$OUT_DIR/pulseo_admin_head.txt" 2>&1 || true

info "6) Export certificat"
sudo certbot certificates > "$OUT_DIR/certificates.txt" 2>&1 || true

info "7) Manifest de hash"
find "$OUT_DIR" -type f -print0 | while IFS= read -r -d '' f; do
  sha256sum "$f"
done | sort > "$OUT_DIR/hash_manifest.txt"

cat > "$OUT_DIR/FROZEN_STATE.md" <<EOM
# Etat fige du socle stable

- Label: $LABEL
- Date: $(date -Is)
- Repo: $REPO_DIR
- Objectif: reference stable avant separation socle / sandbox

## Inclus
- snapshot intelligent
- etat systemd
- etat agent
- config transport
- policy locale
- split public/admin
- etat certificat
- manifest de hash
EOM

info "Etat stable fige dans: $OUT_DIR"
