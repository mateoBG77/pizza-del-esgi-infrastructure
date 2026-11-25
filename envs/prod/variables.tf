variable "aws_region" {
  description = "Région de déploiement (Learner Lab : us-east-1)."
  type        = string
  default     = "us-east-1"
}

variable "owner" {
  description = "Trigramme du référent AWS (variable de dépôt OWNER en CI)."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{3}$", var.owner))
    error_message = "owner : trois lettres minuscules."
  }
}

variable "environment" {
  description = "Nom de l'environnement (terraform.tfvars en local, TF_VAR_environment en CI)."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment doit valoir \"dev\" ou \"prod\"."
  }
}

variable "db_password" {
  description = "Mot de passe de la base, écrit dans Parameter Store (TF_VAR_db_password en CI, jamais dans un fichier)."
  type        = string
  sensitive   = true
  ephemeral   = true

  validation {
    condition     = length(var.db_password) >= 16
    error_message = "db_password : 16 caractères minimum."
  }
}


variable "instance_type" {
  description = "Type des instances web"
  type        = string
  default     = "t3.micro"
}
