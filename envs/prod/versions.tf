terraform {
  required_version = ">= 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "pizza-del-esgi"
      ManagedBy   = "Terraform"
      Owner       = var.owner
      Environment = var.environment
      Repository  = "pizza-del-esgi-infrastructure"
    }
  }
}
