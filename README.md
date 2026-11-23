# pizza-del-esgi-infrastructure — Groupe 5

Résilience et réplication cross-région des logs S3 d'un Application Load Balancer.
Pilier DICT dominant : Disponibilité.

## Architecture
(schéma à insérer : EC2 Apache → Target Group → ALB → bucket logs us-east-1 → réplication → bucket us-east-2)

## Arborescence
- bootstrap/ : bucket S3 des states (state local)
- envs/dev, envs/prod : appellent le module terraform-aws-pizza-del-esgi

## Prérequis
Terraform >= 1.11, AWS CLI v2, profil AWS_PROFILE=pizza-del-esgi

## Déploiement
1. bootstrap  2. envs/dev  3. envs/prod

## Correspondance TP original ↔ ressources Terraform
| Étape du TP | Ressource(s) Terraform | Fichier du module |
|---|---|---|
| Serveur web Apache | aws_instance | compute.tf |
| Target Group | aws_lb_target_group, aws_lb_target_group_attachment | alb.tf |
| Application Load Balancer | aws_lb, aws_lb_listener | alb.tf |
| Bucket S3 des logs ALB | aws_s3_bucket (source) + policy | logging.tf |
| Second bucket, autre région | aws_s3_bucket (provider aws.replica) | logging.tf |
| Activation de la réplication | aws_s3_bucket_versioning x2, aws_iam_role, aws_s3_bucket_replication_configuration | logging.tf, iam.tf |
| Access logs vers S3 | bloc access_logs de aws_lb | alb.tf |
| Destruction | terraform destroy (voir section Destruction) | — |

## Destruction
envs/prod → envs/dev → bootstrap

## RTO / RPO et limites
(à rédiger)
