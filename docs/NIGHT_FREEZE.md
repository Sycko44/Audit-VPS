# Night Freeze

## Purpose

Pause moving parts overnight without damaging the foundation.

This freeze does three things:
- captures a local state snapshot
- stops known automation services if they exist
- blocks local git pushes from this machine while freeze is active

## Files

- `ops/night_freeze_vps_and_git.sh`
- `ops/morning_thaw_vps_and_git.sh`

## Enable freeze

```bash
bash ops/night_freeze_vps_and_git.sh
```

## Disable freeze

```bash
bash ops/morning_thaw_vps_and_git.sh
```

## What it does not do

- it does not change GitHub branch protection settings remotely
- it does not shut down the VPS
- it does not make the full filesystem read-only

## Why this is safe tonight

It is a conservative freeze:
- preserve state
- stop known automations
- prevent accidental pushes from this host

The deeper snapshot and simulation doctrine can be finalized later.
