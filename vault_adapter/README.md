# Vault Adapter

Vault arrive apres le Trust Plane maison.

## Regles

- aucune resolution de secret sans decision positive locale
- pas d'exfiltration brute par defaut
- TTL court pour toute valeur resolue
- journalisation systematique de la demande et du contexte

## Flux cible

1. le manifest reference un secret logique
2. la politique locale autorise ou refuse
3. si autorise, l'adaptateur Vault resolve le secret
4. le receipt et l'attestation OPS enregistrent l'evenement

## Modes

- metadata only
- handle only
- short lived materialization
