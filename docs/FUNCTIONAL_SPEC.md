# Functional Specification

## Nom fonctionnel

Cartographie operationnelle profonde du VPS avec preparation de remediation.

## Finalite

Produire un etat des lieux reel, exploitable et actionnable d'un VPS afin de comprendre son architecture vivante, ses composants critiques, ses dependances, ses points d'exposition, ses anomalies et les voies de correction ou d'evolution.

## Objectifs

- comprendre comment le VPS fonctionne reellement
- localiser rapidement les composants critiques
- identifier dependances et points de rupture
- preparer des corrections sans casser la production
- preparer des evolutions ou developpements
- comparer l'etat du serveur dans le temps
- preparer une reconstruction propre si necessaire

## Architecture logique

### 1. Collecte
Extraction des faits bruts : systeme, reseau, DNS, utilisateurs, services, paquets, containers, fichiers, logs, permissions, certificats et persistance.

### 2. Analyse
Qualification, correlation et scoring :
- port -> processus -> service -> configuration
- domaine -> reverse proxy -> certificat -> backend
- utilisateur -> sudo -> cles -> cron -> shell
- container -> image -> volume -> port -> compose
- fichier -> proprietaire -> role -> criticite

### 3. Synthese
Generation de vues :
- executive
- admin systeme
- developpement
- securite
- exploitation

### 4. Preparation a l'action
Pour chaque finding important :
- constat
- impact probable
- emplacement
- gravite
- verification suggeree
- precaution avant intervention
- priorite

## Modes

- quick : photo legere et immediate
- deep : cartographie operationnelle reelle
- forensic : approche plus lourde orientee preuve et derive

## Sorties attendues

- summary.md
- system_overview.md
- architecture_map.md
- exposure_map.md
- control_map.md
- dev_map.md
- risk_report.md
- remediation_candidates.md
- files_manifest.csv
- objects.json
- relationships.json
- findings.json
- hash_manifest.txt
- run.log

## Definition du succes

Le systeme est reussi si un humain competent peut, apres execution :
- comprendre l'architecture reelle du VPS
- localiser les briques utiles
- reperer rapidement les anomalies
- savoir par ou commencer une correction
- savoir ou developper proprement
- savoir quoi sauvegarder avant d'intervenir
- preparer une reconstruction propre
