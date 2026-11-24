#!/usr/bin/env bash
# Supprime le bucket de state, toutes versions comprises. À lancer en TOUT DERNIER,
# après le destroy de prod et de dev. Usage : scripts/supprimer-bucket-state.sh <nom-du-bucket>
set -euo pipefail

BUCKET="${1:?Usage : $0 <nom-du-bucket>}"
read -r -p "Supprimer définitivement s3://$BUCKET et tous les states ? Tape le nom du bucket : " CONFIRM
[ "$CONFIRM" = "$BUCKET" ] || { echo "Annulé."; exit 1; }

# Un bucket versionné ne se vide pas avec 'aws s3 rm' : il faut supprimer
# chaque version et chaque marqueur de suppression.
for TYPE in Versions DeleteMarkers; do
  while :; do
    OBJETS=$(aws s3api list-object-versions --bucket "$BUCKET" --max-items 500 \
      --query "{Objects: $TYPE[].{Key: Key, VersionId: VersionId}}" --output json)
    [ "$(echo "$OBJETS" | jq '.Objects // [] | length')" -eq 0 ] && break
    aws s3api delete-objects --bucket "$BUCKET" --delete "$OBJETS" >/dev/null
  done
done

aws s3api delete-bucket --bucket "$BUCKET"
echo "Bucket supprimé : $BUCKET"

