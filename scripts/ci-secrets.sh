#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-mateoBG77/pizza-del-esgi-infrastructure}"
PROFIL="${AWS_PROFILE:-default}"
echo "Identité AWS : $(aws sts get-caller-identity --profile "$PROFIL" --query Arn --output text)"
for cle in aws_access_key_id aws_secret_access_key aws_session_token; do
  nom=$(echo "$cle" | tr '[:lower:]' '[:upper:]')
  aws configure get "$cle" --profile "$PROFIL" | gh secret set "$nom" --repo "$REPO"
  echo "  $nom mis à jour"
done

echo "Secrets du dépôt $REPO :"
gh secret list --repo "$REPO"
