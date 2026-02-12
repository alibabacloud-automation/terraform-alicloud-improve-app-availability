# Default user data script for ECS instances
locals {
  default_user_data_script = <<-EOT
    #!/bin/bash
    yum -y install nginx-1.20.1
    instanceId=`curl http://100.100.100.200/latest/meta-data/instance-id`
    echo "This instance from ess, the instance id is $instanceId" > /usr/share/nginx/html/index.html
    systemctl start nginx
    systemctl enable nginx
  EOT
}

# Create VPC
resource "alicloud_vpc" "vpc" {
  vpc_name   = var.vpc_config.vpc_name
  cidr_block = var.vpc_config.cidr_block
}

# Create VSwitches for ECS
resource "alicloud_vswitch" "ecs_vswitches" {
  for_each = { for idx, vswitch in var.ecs_vswitches_config : idx => vswitch }

  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = each.value.cidr_block
  zone_id      = each.value.zone_id
  vswitch_name = each.value.vswitch_name != "improve-app-availability-ecs-vsw" ? each.value.vswitch_name : "${each.value.vswitch_name}-${each.key}"
}

# Create VSwitches for ALB
resource "alicloud_vswitch" "alb_vswitches" {
  for_each = { for idx, vswitch in var.alb_vswitches_config : idx => vswitch }

  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = each.value.cidr_block
  zone_id      = each.value.zone_id
  vswitch_name = each.value.vswitch_name != "improve-app-availability-alb-vsw" ? each.value.vswitch_name : "${each.value.vswitch_name}-${each.key}"
}

# Create Security Group
resource "alicloud_security_group" "security_group" {
  security_group_name = var.security_group_config.security_group_name
  vpc_id              = alicloud_vpc.vpc.id
  description         = var.security_group_config.description
}

# Create Security Group Rules
resource "alicloud_security_group_rule" "security_group_rules" {
  for_each = { for idx, rule in var.security_group_rules_config : "${rule.type}_${rule.port_range}" => rule }

  security_group_id = alicloud_security_group.security_group.id
  type              = each.value.type
  ip_protocol       = each.value.ip_protocol
  port_range        = each.value.port_range
  cidr_ip           = each.value.cidr_ip
  policy            = each.value.policy
  priority          = each.value.priority
}

# Create ALB Load Balancer
resource "alicloud_alb_load_balancer" "alb" {
  load_balancer_name     = var.alb_config.load_balancer_name
  load_balancer_edition  = var.alb_config.load_balancer_edition
  address_allocated_mode = var.alb_config.address_allocated_mode
  vpc_id                 = alicloud_vpc.vpc.id
  address_type           = var.alb_config.address_type

  load_balancer_billing_config {
    pay_type = var.alb_config.pay_type
  }

  dynamic "zone_mappings" {
    for_each = alicloud_vswitch.alb_vswitches
    content {
      zone_id    = zone_mappings.value.zone_id
      vswitch_id = zone_mappings.value.id
    }
  }
}

# Create ALB Server Group
resource "alicloud_alb_server_group" "alb_server_group" {
  server_group_name = var.alb_server_group_config.server_group_name
  vpc_id            = alicloud_vpc.vpc.id
  protocol          = var.alb_server_group_config.protocol

  health_check_config {
    health_check_enabled      = var.alb_server_group_config.health_check_enabled
    health_check_protocol     = var.alb_server_group_config.health_check_protocol
    health_check_path         = var.alb_server_group_config.health_check_path
    health_check_codes        = var.alb_server_group_config.health_check_codes
    health_check_connect_port = var.alb_server_group_config.health_check_connect_port
  }

  sticky_session_config {
    sticky_session_enabled = var.alb_server_group_config.sticky_session_enabled
  }

  lifecycle {
    ignore_changes = [servers]
  }
}

# Create ALB Listener
resource "alicloud_alb_listener" "alb_listener" {
  listener_protocol = var.alb_listener_config.listener_protocol
  listener_port     = var.alb_listener_config.listener_port
  load_balancer_id  = alicloud_alb_load_balancer.alb.id

  default_actions {
    type = var.alb_listener_config.default_action_type
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.alb_server_group.id
      }
    }
  }
}

# Create ESS Scaling Group
resource "alicloud_ess_scaling_group" "ess_scaling_group" {
  scaling_group_name = var.ess_scaling_group_config.scaling_group_name
  min_size           = var.ess_scaling_group_config.min_size
  max_size           = var.ess_scaling_group_config.max_size
  vswitch_ids        = [for vswitch in alicloud_vswitch.ecs_vswitches : vswitch.id]
  removal_policies   = var.ess_scaling_group_config.removal_policies
  default_cooldown   = var.ess_scaling_group_config.default_cooldown
  multi_az_policy    = var.ess_scaling_group_config.multi_az_policy
  az_balance         = var.ess_scaling_group_config.az_balance

  depends_on = [alicloud_security_group.security_group]
}

# Create ESS Server Group Attachment
resource "alicloud_ess_server_group_attachment" "ess_server_group" {
  scaling_group_id = alicloud_ess_scaling_group.ess_scaling_group.id
  server_group_id  = alicloud_alb_server_group.alb_server_group.id
  port             = var.ess_server_group_attachment_config.port
  type             = var.ess_server_group_attachment_config.type
  weight           = var.ess_server_group_attachment_config.weight
  force_attach     = var.ess_server_group_attachment_config.force_attach
}

# Create ESS Scaling Configuration
resource "alicloud_ess_scaling_configuration" "ess_scaling_configuration" {
  scaling_group_id     = alicloud_ess_scaling_group.ess_scaling_group.id
  enable               = var.ess_scaling_configuration_config.enable
  active               = var.ess_scaling_configuration_config.active
  force_delete         = var.ess_scaling_configuration_config.force_delete
  image_id             = var.ess_scaling_configuration_config.image_id
  instance_types       = var.ess_scaling_configuration_config.instance_types
  security_group_id    = alicloud_security_group.security_group.id
  system_disk_category = var.ess_scaling_configuration_config.system_disk_category
  system_disk_size     = var.ess_scaling_configuration_config.system_disk_size
  password             = var.ess_scaling_configuration_config.password
  instance_name        = var.ess_scaling_configuration_config.instance_name
  user_data            = var.custom_user_data_script != null ? var.custom_user_data_script : local.default_user_data_script
}

# Create ESS Scaling Rules
resource "alicloud_ess_scaling_rule" "ess_scaling_rules" {
  for_each = { for idx, rule in var.ess_scaling_rules_config : rule.scaling_rule_name => rule }

  scaling_group_id  = alicloud_ess_scaling_group.ess_scaling_group.id
  scaling_rule_name = each.value.scaling_rule_name
  scaling_rule_type = each.value.scaling_rule_type
  adjustment_type   = each.value.adjustment_type
  adjustment_value  = each.value.adjustment_value
  cooldown          = each.value.cooldown
}

# Create ESS Scheduled Tasks
resource "alicloud_ess_scheduled_task" "ess_scheduled_tasks" {
  for_each = { for idx, task in var.ess_scheduled_tasks_config : task.scheduled_task_name => task }

  scheduled_task_name    = each.value.scheduled_task_name
  launch_time            = each.value.launch_time
  scheduled_action       = alicloud_ess_scaling_rule.ess_scaling_rules[each.value.scaling_rule_name].ari
  launch_expiration_time = each.value.launch_expiration_time
}