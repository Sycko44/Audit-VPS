# Orchestrator Runbook

## Purpose

Provide an autonomous, self-checking, self-repairing runner foundation for Audit-VPS.

## Files

- `orchestrator/runner.sh`
- `orchestrator/lib/common.sh`
- `orchestrator/lib/precheck.sh`
- `orchestrator/lib/plan.sh`
- `orchestrator/lib/apply.sh`
- `orchestrator/lib/repair.sh`
- `orchestrator/lib/verify.sh`
- `orchestrator/lib/receipt.sh`

## Modes

### plan
Collect environment, run prechecks, build a plan, stop.

```bash
bash orchestrator/runner.sh plan
```

### apply
Run prechecks, plan, apply, verify, and if verification fails, attempt repairs.

```bash
bash orchestrator/runner.sh apply
```

### repair
Run repair loop directly.

```bash
bash orchestrator/runner.sh repair
```

## Outputs

State is written under:

```text
.state/<run-id>/
```

Key files:
- `logs/runner.log`
- `artifacts/environment.txt`
- `artifacts/prechecks.txt`
- `artifacts/plan.txt`
- `artifacts/apply.txt`
- `artifacts/verify.txt`
- `artifacts/repair-attempt-*.txt`
- `final-receipt.json`

## Current V1 scope

This orchestrator is a foundation layer. It already provides:
- environment detection
- prechecks
- execution planning
- apply stage
- verification stage
- bounded repair loop
- final receipt

Later iterations can deepen the repair engine and connect it to real deployment actions.
