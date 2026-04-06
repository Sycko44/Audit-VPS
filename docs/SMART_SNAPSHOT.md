# Intelligent Snapshot

## Purpose

This snapshot is a temporary, pragmatic checkpoint taken after finalizing steps 1 through 9 of the trust-plane rollout.

It is not the final snapshot policy model.

## What is frozen now

- final job bundle specification
- Ed25519 verification path
- active local policy gate
- structured receipt format
- Termux agent V1.2 flow
- canonical hub host `pulseo.me`
- Vault-ready trust-gated adapter
- OPS-ready attestation hook

## Why this snapshot exists

- preserve a stable foundation before later redefining the full snapshot strategy
- allow safe comparison before V2
- keep a reproducible checkpoint of the current architecture

## Snapshot command

```bash
bash snapshot/smart_snapshot.sh ./snapshots foundation-step1-to-9 .
```

## Later

A future revision can redefine the real snapshot model, retention and diff strategy.
