variable "vpc_config" {
  description = "Configuration for VPC. The 'cidr_block' attribute is required and cannot be changed after creation."
  type = object({
    vpc_name   = optional(string, "improve-app-availability-vpc")
    cidr_block = string
  })
}

variable "ecs_vswitches_config" {
  description = "List of VSwitch configurations for ECS instances. Each VSwitch requires 'name', 'cidr_block', 'zone_id', and 'vswitch_name'. Note: 'cidr_block' and 'zone_id' cannot be changed after creation."
  type = list(object({
    name         = string
    cidr_block   = string
    zone_id      = string
    vswitch_name = string
  }))
}

variable "alb_vswitches_config" {
  description = "List of VSwitch configurations for ALB. Each VSwitch requires 'name', 'cidr_block', 'zone_id', and 'vswitch_name'. Note: 'cidr_block' and 'zone_id' cannot be changed after creation."
  type = list(object({
    name         = string
    cidr_block   = string
    zone_id      = string
    vswitch_name = string
  }))
}

variable "security_group_config" {
  description = "Configuration for security group. The 'security_group_name' attribute is required."
  type = object({
    security_group_name = string
    description         = optional(string, "Security group for improve app availability")
  })
}

variable "security_group_rules_config" {
  description = "List of security group rule configurations. Each rule requires 'type', 'ip_protocol', 'port_range', and 'cidr_ip'."
  type = list(object({
    type        = string
    ip_protocol = string
    port_range  = string
    cidr_ip     = string
    policy      = optional(string, "accept")
    priority    = optional(number, 1)
  }))
  default = []
}

variable "alb_config" {
  description = "Configuration for ALB load balancer. The 'load_balancer_name' attribute is required."
  type = object({
    load_balancer_name     = string
    load_balancer_edition  = optional(string, "Basic")
    address_allocated_mode = optional(string, "Fixed")
    address_type           = optional(string, "Internet")
    pay_type               = optional(string, "PayAsYouGo")
  })
}


variable "alb_server_group_config" {
  description = "Configuration for ALB server group. The 'server_group_name' attribute is required."
  type = object({
    server_group_name         = string
    protocol                  = optional(string, "HTTP")
    health_check_enabled      = optional(bool, true)
    health_check_protocol     = optional(string, "HTTP")
    health_check_path         = optional(string, "/")
    health_check_codes        = optional(list(string), ["http_2xx", "http_3xx"])
    health_check_connect_port = optional(number, 80)
    sticky_session_enabled    = optional(bool, false)
  })
}

variable "alb_listener_config" {
  description = "Configuration for ALB listener. The 'listener_protocol' and 'listener_port' attributes are required."
  type = object({
    listener_protocol   = string
    listener_port       = number
    default_action_type = optional(string, "ForwardGroup")
  })
}

variable "ess_scaling_group_config" {
  description = "Configuration for ESS scaling group. The 'scaling_group_name', 'min_size', and 'max_size' attributes are required."
  type = object({
    scaling_group_name = string
    min_size           = number
    max_size           = number
    removal_policies   = optional(list(string), ["NewestInstance"])
    default_cooldown   = optional(number, 300)
    multi_az_policy    = optional(string, "COMPOSABLE")
    az_balance         = optional(bool, true)
  })
}

variable "ess_server_group_attachment_config" {
  description = "Configuration for ESS server group attachment. The 'port' attribute is required."
  type = object({
    port         = number
    type         = optional(string, "ALB")
    weight       = optional(number, 100)
    force_attach = optional(bool, true)
  })
}

variable "ess_scaling_configuration_config" {
  description = "Configuration for ESS scaling configuration. The 'image_id', 'instance_types', 'password', and 'instance_name' attributes are required."
  type = object({
    enable               = optional(bool, true)
    active               = optional(bool, true)
    force_delete         = optional(bool, true)
    image_id             = string
    instance_types       = list(string)
    system_disk_category = optional(string, "cloud_essd")
    system_disk_size     = optional(number, 40)
    password             = string
    instance_name        = string
  })
}

variable "ess_scaling_rules_config" {
  description = "List of ESS scaling rule configurations. Each rule requires 'name', 'scaling_rule_name', 'scaling_rule_type', 'adjustment_type', 'adjustment_value', and 'cooldown'."
  type = list(object({
    name              = string
    scaling_rule_name = string
    scaling_rule_type = optional(string, "SimpleScalingRule")
    adjustment_type   = string
    adjustment_value  = number
    cooldown          = optional(number, 60)
  }))
  default = []
}

variable "ess_scheduled_tasks_config" {
  description = "List of ESS scheduled task configurations. Each task requires 'name', 'scheduled_task_name', 'launch_time', 'scaling_rule_name', and 'launch_expiration_time'."
  type = list(object({
    name                   = string
    scheduled_task_name    = string
    launch_time            = string
    scaling_rule_name      = string
    launch_expiration_time = optional(number, 10)
  }))
  default = []
}

variable "custom_user_data_script" {
  description = "Custom user data script for ECS instance initialization. If not provided, the default script will be used."
  type        = string
  default     = null
}