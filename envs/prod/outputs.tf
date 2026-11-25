output "vpc_id" {
  description = "Identifiant du VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Identifiants des subnets publics"
  value       = module.vpc.public_subnets
}

output "alb_dns_name" {
  description = "Nom DNS public de l'ALB"
  value       = module.web.alb_dns_name
}

output "target_group_arn" {
  description = "ARN du groupe cible"
  value       = module.web.target_group_arn
}

output "asg_name" {
  description = "Nom du groupe Auto Scaling"
  value       = module.web.asg_name
}
