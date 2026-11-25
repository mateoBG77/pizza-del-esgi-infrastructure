# Reseau public sur deux zones de disponibilite, sans NAT Gateway.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.0"

  name = "pizza-del-esgi-${var.environment}"

  cidr = var.environment == "dev" ? "10.0.0.0/16" : "10.1.0.0/16"

  azs = ["us-east-1a", "us-east-1b"]

  public_subnets = var.environment == "dev" ? [
    "10.0.1.0/24",
    "10.0.2.0/24"
    ] : [
    "10.1.1.0/24",
    "10.1.2.0/24"
  ]

  enable_nat_gateway      = false
  map_public_ip_on_launch = true
  enable_dns_support      = true
  enable_dns_hostnames    = true
}
