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
