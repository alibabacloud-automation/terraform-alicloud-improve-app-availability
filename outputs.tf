# VPC outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = alicloud_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = alicloud_vpc.vpc.cidr_block
}

# VSwitch outputs
output "ecs_vswitch_ids" {
  description = "Map of ECS VSwitch indices to their IDs"
  value       = { for idx, vswitch in alicloud_vswitch.ecs_vswitches : idx => vswitch.id }
}

output "alb_vswitch_ids" {
  description = "Map of ALB VSwitch indices to their IDs"
  value       = { for idx, vswitch in alicloud_vswitch.alb_vswitches : idx => vswitch.id }
}

# Security Group outputs
output "security_group_id" {
  description = "The ID of the security group"
  value       = alicloud_security_group.security_group.id
}

# ALB outputs
output "alb_id" {
  description = "The ID of the ALB load balancer"
  value       = alicloud_alb_load_balancer.alb.id
}

output "alb_dns_name" {
  description = "The DNS name of the ALB load balancer"
  value       = alicloud_alb_load_balancer.alb.dns_name
}

output "alb_server_group_id" {
  description = "The ID of the ALB server group"
  value       = alicloud_alb_server_group.alb_server_group.id
}

output "alb_listener_id" {
  description = "The ID of the ALB listener"
  value       = alicloud_alb_listener.alb_listener.id
}

# ESS outputs
output "ess_scaling_group_id" {
  description = "The ID of the ESS scaling group"
  value       = alicloud_ess_scaling_group.ess_scaling_group.id
}

output "ess_scaling_configuration_id" {
  description = "The ID of the ESS scaling configuration"
  value       = alicloud_ess_scaling_configuration.ess_scaling_configuration.id
}

output "ess_scaling_rule_ids" {
  description = "Map of ESS scaling rule names to their IDs"
  value       = { for name, rule in alicloud_ess_scaling_rule.ess_scaling_rules : name => rule.id }
}

output "ess_scaling_rule_aris" {
  description = "Map of ESS scaling rule names to their ARIs"
  value       = { for name, rule in alicloud_ess_scaling_rule.ess_scaling_rules : name => rule.ari }
}

output "ess_scheduled_task_ids" {
  description = "Map of ESS scheduled task names to their IDs"
  value       = { for name, task in alicloud_ess_scheduled_task.ess_scheduled_tasks : name => task.id }
}

# Web access URL
output "web_url" {
  description = "The web access URL of the application"
  value       = format("http://%s", alicloud_alb_load_balancer.alb.dns_name)
}