# Output Schema Overview

## objects.json
List of normalized objects discovered during collection and analysis.

Minimum fields:
- `id`
- `kind`
- `name`
- `path`
- `tags`
- `risk_level`
- `sensitivity`
- `status`
- `source_refs`

Kinds may include:
- host
- interface
- ip
- route
- resolver
- service
- process
- user
- group
- ssh_key
- cron_job
- timer
- package
- runtime
- app
- git_repo
- container
- image
- volume
- database
- certificate
- file
- directory
- finding

## relationships.json
Directed edges linking normalized objects.

Minimum fields:
- `from`
- `to`
- `type`
- `confidence`
- `source_refs`

Example relationship types:
- listens_on
- owned_by
- managed_by
- configured_by
- proxies_to
- uses_certificate
- starts_with
- mounts
- stores_data_in
- runs_as
- scheduled_by

## findings.json
List of notable findings and anomalies.

Minimum fields:
- `id`
- `title`
- `category`
- `severity`
- `summary`
- `affected_objects`
- `evidence`
- `suggested_checks`
- `precautions`
- `status`

## files_manifest.csv
One line per relevant file.

Suggested columns:
- path
- type
- mime
- size
- owner
- group
- mode_octal
- mode_human
- mtime
- ctime
- inode
- sha256
- sensitivity
- role_guess
- preview_path

## hash_manifest.txt
Line-based manifest of key output files and their hashes.

Format:
- `<sha256>  <relative_path>`

## run.log
Complete collector execution log with module boundaries and failures.
