# Job Bundle Specification

## Canonical job layout

```text
jobs/<job_id>/
  payload.sh
  manifest.json
  manifest.sig
  policy.json
```

## Canonical host

All examples, agents and transport helpers must prefer:

- `HUB_HOST=pulseo.me`

## manifest.json

Mandatory fields:
- `job_id`
- `payload`
- `sha256`
- `signing_key_id`
- `created_at`
- `policy_ref`
- `allowed_payload_kind`
- `target_scope`
- `receipts_to`

Optional fields:
- `secret_refs`
- `notes`
- `expires_at`
- `attestation_required`

### Example

```json
{
  "job_id": "job-20260407-001",
  "payload": "payload.sh",
  "sha256": "<payload sha256>",
  "signing_key_id": "trustplane-ed25519-main",
  "created_at": "2026-04-07T12:00:00Z",
  "policy_ref": "default-local-deny",
  "allowed_payload_kind": "audit",
  "target_scope": "termux-agent",
  "secret_refs": [],
  "receipts_to": "pulseo.me:/home/USER_OVH/agent_hub/receipts",
  "attestation_required": true
}
```

## policy.json

Mandatory fields:
- `policy_id`
- `default`
- `trusted_signing_keys`
- `allowed_payload_kinds`
- `allowed_target_scopes`
- `allow_secret_resolution`

## receipt.json

Mandatory fields:
- `job_id`
- `status`
- `policy_allow`
- `policy_reason`
- `payload_sha256`
- `manifest_sha256`
- `agent_id`
- `hub_host`
- `started_at`
- `finished_at`
- `exit_code`
- `attested`
- `signed`

## Signature model

Preferred signing model for V1.1 finalization:
- Ed25519 signatures through `ssh-keygen -Y sign` and `ssh-keygen -Y verify`

Fallbacks may exist later, but the canonical path is Ed25519.
