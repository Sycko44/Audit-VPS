# V1 Runbook

## Preconditions

- Linux target host
- shell access with enough privileges to inspect the system
- Python 3 available for analyzer stage
- optional root privileges for deeper visibility

## 1. Clone the repository

```bash
git clone https://github.com/Sycko44/Audit-VPS.git
cd Audit-VPS
```

## 2. Run collector on target host

Quick mode:

```bash
bash collector/audit-vps.sh quick
```

Deep mode:

```bash
bash collector/audit-vps.sh deep
```

Forensic mode:

```bash
bash collector/audit-vps.sh forensic
```

Collector outputs will be written under:

```text
output/<host>/<timestamp>/
```

## 3. Run analyzer

Find the latest output directory, then analyze it:

```bash
python3 analyzer/analyze.py output/<host>/<timestamp>
```

## 4. Review generated reports

Read the generated markdown files under:

```text
output/<host>/<timestamp>/summary/
```

Priority files:
- `summary.md`
- `system_overview.md`
- `architecture_map.md`
- `exposure_map.md`
- `risk_report.md`
- `remediation_candidates.md`

## 5. V1 limits

This V1 is intentionally pragmatic.

It already provides:
- local collection modules
- file inventory with hashes and text previews
- first-pass findings
- machine-readable JSON outputs
- markdown synthesis
- stable project structure for V2 expansion

Still expected for later iterations:
- stronger redaction engine
- richer service-to-port correlation
- baseline and diff implementation
- better TLS and reverse-proxy parsing
- deeper distro-awareness and fallback coverage
