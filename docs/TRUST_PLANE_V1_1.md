# Trust Plane V1.1

## Principe

La couche de confiance maison passe avant toute resolution de secret ou execution de payload.

Ordre logique :
1. verification du bundle
2. verification du manifest
3. verification de signature
4. decision de politique locale
5. execution isolee si autorisee
6. emission d'un receipt signe
7. resolution Vault seulement si la politique l'autorise
8. attestation OPS et journalisation

## Buts

- deny by default
- integrite verifiable
- traçabilite de bout en bout
- non-exfiltration des secrets par defaut
- usage de Vault comme backend et non comme source primaire de confiance

## Objets clefs

- `manifest.json`
- `manifest.sig`
- `policy.json`
- `receipt.json`
- `decision.json`
- `secret_references.json`

## Injection dans le flux

Le transport et l'execution doivent cesser d'etre centres sur `deploy_*.sh` seuls.
Le nouveau flux consomme des jobs bundles signes, par exemple :

```text
jobs/job-20260407-001/
  payload.sh
  manifest.json
  manifest.sig
  policy.json
```

## Canonical host

Le hub distant doit etre reference via un hote canonique unique :
- `pulseo.me`

Les IPs directes et noms OVH temporaires doivent etre consideres comme des valeurs de secours, pas comme reference primaire.
