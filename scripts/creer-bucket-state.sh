#!/usr/bin/env bash
# Crée le bucket S3 d'équipe qui stocke les states Terraform de dev et prod.
# Learner Lab : le bucket de state se crée à la CLI (pas de ressource aws_s3_bucket).
# Usage : scripts/creer-bucket-state.sh <nom-du-bucket>
set -euo pipefail

BUCKET="${1:?Usage : $0 <nom-du-bucket>}"
REGION="us-east-1"

echo "Création de s3://$BUCKET ($REGION)"
aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" >/dev/null
aws s3api wait bucket-exists --bucket "$BUCKET"

# Blocage de tout accès public
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Versioning : chaque écriture du state garde la version précédente
aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

# Chiffrement au repos par défaut (SSE-S3, AES-256)
aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# Chiffrement en transit : toute requête non HTTPS est refusée
aws s3api put-bucket-policy --bucket "$BUCKET" --policy "{
  \"Version\": \"2012-10-17\",
  \"Statement\": [{
    \"Sid\": \"DenyInsecureTransport\",
    \"Effect\": \"Deny\",
    \"Principal\": \"*\",
    \"Action\": \"s3:*\",
    \"Resource\": [\"arn:aws:s3:::$BUCKET\", \"arn:aws:s3:::$BUCKET/*\"],
    \"Condition\": {\"Bool\": {\"aws:SecureTransport\": \"false\"}}
  }]
}"

# Coût maîtrisé : les anciennes versions du state sont purgées après 30 jours
aws s3api put-bucket-lifecycle-configuration --bucket "$BUCKET" \
  --lifecycle-configuration \
  '{"Rules":[{"ID":"purge-anciennes-versions","Status":"Enabled","Filter":{},"NoncurrentVersionExpiration":{"NoncurrentDays":30},"AbortIncompleteMultipartUpload":{"DaysAfterInitiation":7}}]}'

# Tags (le bucket n'est pas géré par Terraform, donc pas de default_tags)
aws s3api put-bucket-tagging --bucket "$BUCKET" --tagging \
  'TagSet=[{Key=Project,Value=pizza-del-esgi},{Key=Component,Value=tfstate},{Key=ManagedBy,Value=aws-cli},{Key=Owner,Value=equipe-pizza-del-esgi}]'

echo "Bucket prêt : $BUCKET"
