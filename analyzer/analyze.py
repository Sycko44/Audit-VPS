#!/usr/bin/env python3
from __future__ import annotations

import csv
import hashlib
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Any

RAW_FILES = [
    'identity.txt',
    'storage.txt',
    'network.txt',
    'dns_tls.txt',
    'users_access.txt',
    'persistence.txt',
    'services.txt',
    'apps_dev.txt',
    'containers.txt',
    'databases.txt',
    'findings_first_pass.txt',
]


def slurp(path: Path) -> str:
    try:
        return path.read_text(encoding='utf-8', errors='replace')
    except FileNotFoundError:
        return ''


def count_nonempty_lines(text: str) -> int:
    return sum(1 for line in text.splitlines() if line.strip())


def build_objects(out_root: Path) -> list[dict[str, Any]]:
    raw_dir = out_root / 'raw'
    objects: list[dict[str, Any]] = []
    for name in RAW_FILES:
        path = raw_dir / name
        text = slurp(path)
        if not text:
            continue
        objects.append(
            {
                'id': f'raw:{name}',
                'kind': 'raw_capture',
                'name': name,
                'path': str(path),
                'tags': ['raw', 'collector'],
                'risk_level': 'informational',
                'sensitivity': 'unknown',
                'status': 'present',
                'source_refs': [str(path)],
                'metrics': {
                    'bytes': len(text.encode('utf-8', errors='ignore')),
                    'nonempty_lines': count_nonempty_lines(text),
                },
            }
        )
    manifest = out_root / 'manifests' / 'files_manifest.csv'
    if manifest.exists():
        objects.append(
            {
                'id': 'manifest:files',
                'kind': 'file_manifest',
                'name': 'files_manifest.csv',
                'path': str(manifest),
                'tags': ['manifest', 'files'],
                'risk_level': 'informational',
                'sensitivity': 'mixed',
                'status': 'present',
                'source_refs': [str(manifest)],
            }
        )
    return objects


def build_relationships(out_root: Path) -> list[dict[str, Any]]:
    rels: list[dict[str, Any]] = []
    services = slurp(out_root / 'raw' / 'services.txt')
    network = slurp(out_root / 'raw' / 'network.txt')
    dns_tls = slurp(out_root / 'raw' / 'dns_tls.txt')

    if services and network:
        rels.append(
            {
                'from': 'raw:services.txt',
                'to': 'raw:network.txt',
                'type': 'correlates_with',
                'confidence': 0.6,
                'source_refs': ['raw/services.txt', 'raw/network.txt'],
            }
        )
    if dns_tls and network:
        rels.append(
            {
                'from': 'raw:dns_tls.txt',
                'to': 'raw:network.txt',
                'type': 'exposure_context_for',
                'confidence': 0.5,
                'source_refs': ['raw/dns_tls.txt', 'raw/network.txt'],
            }
        )
    return rels


def detect_findings(out_root: Path) -> list[dict[str, Any]]:
    findings: list[dict[str, Any]] = []
    first_pass = slurp(out_root / 'raw' / 'findings_first_pass.txt')
    services = slurp(out_root / 'raw' / 'services.txt')
    network = slurp(out_root / 'raw' / 'network.txt')
    users = slurp(out_root / 'raw' / 'users_access.txt')

    if '0.0.0.0:' in network or '[::]:' in network:
        findings.append(
            {
                'id': 'finding:public-listeners',
                'title': 'Possible public listeners detected',
                'category': 'exposure',
                'severity': 'medium',
                'summary': 'One or more listening sockets appear bound broadly. Review intended exposure.',
                'affected_objects': ['raw:network.txt', 'raw:services.txt'],
                'evidence': ['Broad listener patterns found in network capture'],
                'suggested_checks': ['Review ss -tulpn output', 'Confirm reverse proxy and firewall policy'],
                'precautions': ['Do not close ports before mapping service ownership'],
                'status': 'open',
            }
        )

    if '== world writable files ==' in first_pass:
        ww_lines = [l for l in first_pass.splitlines() if l.startswith('/')]
        if ww_lines:
            findings.append(
                {
                    'id': 'finding:world-writable',
                    'title': 'World writable files present',
                    'category': 'permissions',
                    'severity': 'high',
                    'summary': f'{len(ww_lines)} potentially risky file paths were found with broad write access.',
                    'affected_objects': ['raw:findings_first_pass.txt'],
                    'evidence': ww_lines[:10],
                    'suggested_checks': ['Validate each path owner and purpose', 'Tighten mode where not required'],
                    'precautions': ['Do not modify shared runtime sockets or expected temp artifacts blindly'],
                    'status': 'open',
                }
            )

    if re.search(r'failed', services, re.IGNORECASE):
        findings.append(
            {
                'id': 'finding:failed-services',
                'title': 'Failed or degraded services may exist',
                'category': 'availability',
                'severity': 'medium',
                'summary': 'The services capture suggests at least one failed or degraded unit.',
                'affected_objects': ['raw:services.txt'],
                'evidence': ['Search for failed units in raw/services.txt'],
                'suggested_checks': ['Inspect systemctl --failed', 'Check journal logs around service startup'],
                'precautions': ['Map dependencies before restarting critical services'],
                'status': 'open',
            }
        )

    if 'sudoers' in users and '/root/.ssh' in users:
        findings.append(
            {
                'id': 'finding:privileged-access-review',
                'title': 'Privileged access paths detected',
                'category': 'access',
                'severity': 'informational',
                'summary': 'Sudo and SSH materials were collected. Access paths should be reviewed manually.',
                'affected_objects': ['raw:users_access.txt'],
                'evidence': ['sudoers and SSH paths present in capture'],
                'suggested_checks': ['Review privileged users', 'Review SSH key hygiene and shell access'],
                'precautions': ['Do not rotate or delete active keys before tracing ownership'],
                'status': 'open',
            }
        )

    return findings


def summarize_manifest(out_root: Path) -> dict[str, Any]:
    manifest = out_root / 'manifests' / 'files_manifest.csv'
    if not manifest.exists():
        return {'files': 0, 'text_previews': 0}

    files = 0
    previews = 0
    with manifest.open('r', encoding='utf-8', errors='replace') as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            files += 1
            if row.get('preview_path'):
                previews += 1
    return {'files': files, 'text_previews': previews}


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def write_markdown(out_root: Path, findings: list[dict[str, Any]], stats: dict[str, Any]) -> None:
    summary_dir = out_root / 'summary'
    summary_dir.mkdir(parents=True, exist_ok=True)

    architecture = summary_dir / 'architecture_map.md'
    exposure = summary_dir / 'exposure_map.md'
    control = summary_dir / 'control_map.md'
    dev = summary_dir / 'dev_map.md'
    risks = summary_dir / 'risk_report.md'
    remediation = summary_dir / 'remediation_candidates.md'
    system_overview = summary_dir / 'system_overview.md'
    summary = summary_dir / 'summary.md'

    architecture.write_text(
        '# Architecture Map\n\n'
        '- Raw captures available under `raw/`\n'
        '- File manifest available under `manifests/files_manifest.csv`\n'
        '- Relationships available under `maps/relationships.json`\n',
        encoding='utf-8',
    )

    exposure.write_text(
        '# Exposure Map\n\n'
        '- Review `raw/network.txt` for listeners and routes\n'
        '- Review `raw/dns_tls.txt` for hostname, vhost and cert hints\n',
        encoding='utf-8',
    )

    control.write_text(
        '# Control Map\n\n'
        '- Review `raw/users_access.txt` for users, groups, sudo and SSH materials\n'
        '- Review `raw/persistence.txt` for systemd and cron persistence\n',
        encoding='utf-8',
    )

    dev.write_text(
        '# Dev Map\n\n'
        '- Review `raw/apps_dev.txt` for runtimes, Git repos and app hints\n'
        '- Review `raw/containers.txt` for containers and compose footprints\n'
        '- Review `raw/databases.txt` for database engines and data hints\n',
        encoding='utf-8',
    )

    risk_lines = ['# Risk Report', '', f'- Findings detected: {len(findings)}', '']
    for finding in findings:
        risk_lines.extend([
            f"## {finding['title']}",
            '',
            f"- Severity: {finding['severity']}",
            f"- Category: {finding['category']}",
            f"- Summary: {finding['summary']}",
            '',
        ])
    risks.write_text('\n'.join(risk_lines) + '\n', encoding='utf-8')

    rem_lines = ['# Remediation Candidates', '']
    for finding in findings:
        rem_lines.append(f"## {finding['title']}")
        rem_lines.append('')
        rem_lines.append('Suggested checks:')
        for check in finding.get('suggested_checks', []):
            rem_lines.append(f'- {check}')
        rem_lines.append('')
        rem_lines.append('Precautions:')
        for p in finding.get('precautions', []):
            rem_lines.append(f'- {p}')
        rem_lines.append('')
    remediation.write_text('\n'.join(rem_lines) + '\n', encoding='utf-8')

    system_overview.write_text(
        '# System Overview\n\n'
        f"- Generated: {datetime.utcnow().isoformat()}Z\n"
        f"- Files indexed: {stats['files']}\n"
        f"- Text previews: {stats['text_previews']}\n",
        encoding='utf-8',
    )

    summary.write_text(
        '# Audit-VPS Summary\n\n'
        f"- Generated: {datetime.utcnow().isoformat()}Z\n"
        f"- Files indexed: {stats['files']}\n"
        f"- Text previews: {stats['text_previews']}\n"
        f"- Findings: {len(findings)}\n\n"
        'See also:\n'
        '- `system_overview.md`\n'
        '- `architecture_map.md`\n'
        '- `exposure_map.md`\n'
        '- `control_map.md`\n'
        '- `dev_map.md`\n'
        '- `risk_report.md`\n'
        '- `remediation_candidates.md`\n',
        encoding='utf-8',
    )


def write_output_hashes(out_root: Path) -> None:
    manifest = out_root / 'manifests' / 'hash_manifest.txt'
    lines = []
    for path in sorted(p for p in out_root.rglob('*') if p.is_file() and p.name != 'hash_manifest.txt'):
        sha = hashlib.sha256(path.read_bytes()).hexdigest()
        lines.append(f'{sha}  {path.relative_to(out_root)}')
    manifest.write_text('\n'.join(lines) + ('\n' if lines else ''), encoding='utf-8')


def main() -> int:
    if len(sys.argv) != 2:
        print('Usage: analyze.py <collector_output_dir>', file=sys.stderr)
        return 2

    out_root = Path(sys.argv[1]).resolve()
    if not out_root.exists():
        print(f'Missing output directory: {out_root}', file=sys.stderr)
        return 2

    objects = build_objects(out_root)
    relationships = build_relationships(out_root)
    findings = detect_findings(out_root)
    stats = summarize_manifest(out_root)

    write_json(out_root / 'maps' / 'objects.json', objects)
    write_json(out_root / 'maps' / 'relationships.json', relationships)
    write_json(out_root / 'maps' / 'findings.json', findings)
    write_markdown(out_root, findings, stats)
    write_output_hashes(out_root)

    print(f'Analysis completed for {out_root}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
