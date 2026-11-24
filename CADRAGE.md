# Fiche de cadrage — Pizza del ESGI (groupe 5)

## Équipe

| Membre | Compte GitHub | Rôle | Brique |
|---|---|---|---|
| Mateo | `mateoBG77` | Référent AWS, référent Git | Mise en place + CI/CD |
| Prisca | `Priisk` | Membre | Module « pile web » |
| Thiviya | `thiviya30` | Suppléante AWS | Environnements + extension |
| Yannis | `Yvns1` | Membre | Secret, page et sécurité |

- **Learner Lab de l'équipe** : celui de Mateo (us-east-1). Il porte le bucket de state `pizza-del-esgi-tfstate-mca`, l'infrastructure et les identifiants de la CI.
- **Suppléante** : si le référent manque, Thiviya crée son propre bucket, redéploie depuis le code dans son lab et fait remplacer les secrets du dépôt.
- **Dépôts publics** : projet `mateoBG77/pizza-del-esgi-infrastructure`, module `mateoBG77/terraform-aws-pizza-del-esgi`. Collaborateurs : les quatre membres et l'intervenant.

## Contexte

**Pizza del ESGI** est une pizzeria fictive qui publie la carte de ses pizzas sur une page web.
Les instances servent une page HTML statique (nginx) derrière un Application Load Balancer.
Deux environnements identiques : **dev** et **prod**.
La page affiche l'environnement, l'instance qui répond et « secret chargé : oui ». La valeur du secret ne s'affiche jamais.
Le secret `/pizza-del-esgi/<env>/db_password` (SecureString, `value_wo`) est lu au démarrage grâce à `LabInstanceProfile`.

## Répartition

| Membre | Contenu | Fichiers |
|---|---|---|
| Mateo | Dépôts, bucket de state à la CLI, backends dev/prod, contrat d'interface du module, recopie des identifiants du lab, CI des PR (fmt, validate, plan en commentaire), apply de dev au merge, prod avec approbation, job de dérive, protection de `main` et environnement `prod` | `scripts/`, `envs/*/backend.tf`, `envs/*/versions.tf`, `.github/workflows/`, `CADRAGE.md`, `CONTRIBUTING.md`, `README.md` (assemblage) |
| Prisca | SG de l'ALB, SG web (n'accepte que le SG de l'ALB), Launch Template (IMDSv2 exigé, `LabInstanceProfile`), ALB, target group, listener, ASG (min 2, `health_check_type = "ELB"`), validations, outputs, tag `v1.0.0` puis un tag par évolution | module : `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf` ; section « module » de `ARCHITECTURE.md` |
| Thiviya | VPC du registre (2 zones, sans NAT Gateway), AMI, appel du module par tag, dev et prod identiques sauf les variables ; extension | `envs/*/network.tf`, `main.tf`, `variables.tf`, `terraform.tfvars.example`, `outputs.tf` ; sections « déployer, vérifier, détruire » du `README.md` |
| Yannis | Un secret SecureString en `value_wo` par environnement ; amorçage (nginx, page du menu, environnement, « secret chargé : oui ») passé par `templatefile` ; scan checkov avec correction ou justification de chaque résultat ; politique IAM idéale et écart avec OIDC | `envs/*/secrets.tf`, `bootstrap.sh` (dépôt du module), `SECURITE.md`, `ci_oidc_compte_classique.tf.exemple` |

Chacun travaille dans sa branche, passe par une PR relue par un autre membre (en tournant), teste dans son propre Learner Lab puis détruit tout, et commite sous son nom depuis son poste.

## Extension : administration sans SSH

- Une opération d'administration scriptée par SSM Run Command (`aws ssm send-command`) sur les instances de l'ASG.
- Suppression de toute paire de clés (`aws_key_pair`) du code.
- En plus du socle : aucune ressource facturée, l'agent SSM et `LabInstanceProfile` suffisent. Temps estimé : une demi-journée.

## Ce que l'équipe écarte

| Écarté | Raison |
|---|---|
| NAT Gateway | Inutile (instances en subnets publics) et facturée à l'heure |
| Workspaces Terraform | Interdits : deux dossiers `envs/dev` et `envs/prod`, deux clés de state |
| OIDC GitHub → AWS appliqué | Le Learner Lab interdit de créer le rôle IAM ; identifiants de session recopiés par `scripts/ci-secrets.sh`, OIDC fourni en `.exemple` |
| Ressource `aws_s3_bucket` pour le state | Le bucket doit exister avant le premier `init`, et le lab refuse un appel de cette ressource : créé à la CLI |
| HTTPS | Pas de domaine dans le lab ; seul un certificat autosigné serait possible |
| Base de données RDS | Allonge chaque apply et chaque destroy ; hors du temps disponible |

## Validation

Validée par l'intervenant le ____________ : ☐ telle quelle ☐ réduite à : ____________________________
