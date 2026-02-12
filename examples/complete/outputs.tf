output "web_url" {
  description = "The web access URL of the application"
  value       = module.improve_app_availability.web_url
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.improve_app_availability.vpc_id
}

output "alb_dns_name" {
  description = "The DNS name of the ALB load balancer"
  value       = module.improve_app_availability.alb_dns_name
}

output "ess_scaling_group_id" {
  description = "The ID of the ESS scaling group"
  value       = module.improve_app_availability.ess_scaling_group_id
}

output "ess_scaling_rule_aris" {
  description = "Map of ESS scaling rule names to their ARIs"
  value       = module.improve_app_availability.ess_scaling_rule_aris
}