# pulseo.me Pointing

## Regle projet

`pulseo.me` devient l'hote canonique du hub.

Les scripts, exemples et variables d'environnement doivent pointer en priorite vers :

- `HUB_HOST=pulseo.me`

## Pourquoi

- eviter les references eparses a une IP ou a un hostname OVH variable
- centraliser la bascule DNS
- garder un point d'entree stable pour Termux, agents et outillage

## Ce que cela corrige

- divergence entre configs locales et config serveur
- couplage au hostname OVH temporaire
- maintenance plus dure lors d'un changement d'IP ou de VPS

## Checklist de correction

- remplacer les exemples `HOST_OVH` par `pulseo.me`
- introduire `HUB_HOST` comme variable canonique
- garder une `HUB_HOST_FALLBACK` seulement en secours
- verifier que le service expose sur le VPS repond bien pour `pulseo.me`
- verifier les enregistrements DNS, reverse proxy et certificats

## Verification cible

La verification finale doit couvrir :
- DNS : `pulseo.me` resolu vers le bon VPS
- web/proxy : `server_name pulseo.me` ou equivalent
- TLS : certificat couvrant `pulseo.me`
- SSH/agents : `HUB_HOST=pulseo.me`
