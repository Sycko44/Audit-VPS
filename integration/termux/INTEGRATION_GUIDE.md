# Termux Integration Guide

## But

Remplacer le vieux flux centre sur `deploy_*.sh` par un flux de jobs bundles signes, avec `pulseo.me` comme hub canonique.

## Nouveau flux

1. pull du bundle depuis `pulseo.me`
2. verification du manifest
3. verification de signature
4. decision locale de politique
5. execution si autorisee
6. ecriture du receipt
7. push du receipt vers `pulseo.me`

## Fichiers cles

- `integration/termux/agent_termux_v1_1.sh`
- `transport/job.env.example`
- `security_core/verify_manifest.sh`
- `security_core/verify_signature.sh`
- `security_core/policy_gate.sh`
- `security_core/write_receipt.sh`

## Variables canoniques

- `HUB_HOST=pulseo.me`
- `HUB_PORT=22`
- `HUB_JOB_DIR=/home/USER_OVH/agent_hub/jobs`
- `HUB_RECEIPT_DIR=/home/USER_OVH/agent_hub/receipts`

## Migration depuis l'ancien agent

- remplacer le polling de `deploy_*.sh` par le pull de dossiers de jobs
- ne plus executer un script tant que manifest, signature et politique n'ont pas ete traites
- ecrire un receipt meme en cas de refus
- normaliser tous les hostnames vers `pulseo.me`

## Etat V1.1

La structure est en place et le branchement principal est fait.
Les prochaines etapes consistent a brancher la vraie verification Ed25519 et la vraie politique locale maison.
