# Technical Execution Plan

## Project structure

```text
Audit-VPS/
  docs/
  collector/
    audit-vps.sh
    lib/
  analyzer/
    analyze.py
    requirements.txt
  schemas/
  examples/
```

## Execution flow

### Phase A - Local collector
Runs on target host.

Responsibilities:
- detect environment and available tools
- create timestamped output directory
- execute collection modules with timeouts and bounded reads
- build raw outputs, manifests and hashes
- avoid destructive actions

### Phase B - Off-host analyzer
Runs outside the target host when possible.

Responsibilities:
- parse raw outputs and manifests
- classify objects
- build relationships and findings
- compute scores
- generate human-readable synthesis
- compare with previous baselines

## Collector modules

- `common.sh` : shared helpers, logging, timeouts, redaction helpers
- `collect_identity.sh` : OS, kernel, host identity, virtualization, uptime
- `collect_storage.sh` : disks, mounts, FS, saturation, top files
- `collect_network.sh` : interfaces, IPs, routes, sockets, exposure
- `collect_dns_tls.sh` : resolvers, hostnames, vhosts, certificates
- `collect_users_access.sh` : users, groups, sudo, SSH, sessions
- `collect_persistence.sh` : systemd, timers, cron, boot scripts
- `collect_services.sh` : service states, process mapping, logs
- `collect_apps_dev.sh` : runtimes, repos, apps, deployment scripts
- `collect_containers.sh` : Docker, Compose, Podman, K8s if present
- `collect_databases.sh` : DB engines, configs, sockets, logs
- `collect_files.sh` : intelligent inventory of files
- `collect_findings.sh` : first-pass anomaly extraction

## Analyzer pipeline

1. load raw outputs
2. normalize objects
3. create relationship edges
4. assign tags and risk levels
5. compute scores
6. emit reports and machine-readable artifacts

## Modes

### quick
Fast snapshot:
- host identity
- IP / ports / services
- exposure overview
- storage summary
- users overview

### deep
Operational mapping:
- all quick modules
- config correlation
- file inventory with bounded previews
- containers, TLS, cron, findings, scores

### forensic
Extended timeline and drift analysis:
- all deep modules
- stronger timeline extraction
- deeper persistence focus
- baseline and diff

## Output contract

Collector output root:

```text
output/<host>/<timestamp>/
  raw/
  maps/
  manifests/
  previews/
  summary/
  logs/
```

Stable machine-readable files:
- `objects.json`
- `relationships.json`
- `findings.json`
- `files_manifest.csv`
- `hash_manifest.txt`
- `run.log`

Human-readable files:
- `summary.md`
- `architecture_map.md`
- `exposure_map.md`
- `control_map.md`
- `dev_map.md`
- `risk_report.md`
- `remediation_candidates.md`

## Design constraints

- safe by default
- continue on module failure
- bounded reads and timeouts
- secret-aware redaction
- distro-aware fallbacks
- low-friction baseline and diff
