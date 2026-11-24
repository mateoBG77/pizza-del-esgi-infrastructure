# Secret de l'environnement, lu au démarrage par les instances (LabInstanceProfile).
# value_wo : la valeur est envoyée à AWS mais jamais écrite dans le state.
resource "aws_ssm_parameter" "db_password" {
  name        = "/pizza-del-esgi/${var.environment}/db_password"
  description = "Mot de passe de la base (${var.environment})"
  type        = "SecureString"

  value_wo         = var.db_password
  value_wo_version = 1 # augmenter de 1 pour pousser un nouveau mot de passe
}
