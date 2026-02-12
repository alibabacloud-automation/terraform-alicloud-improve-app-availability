variable "vpc_config" {
  description = "Configuration for VPC. The 'cidr_block' attribute is required and cannot be changed after creation."
  type = object({
    vpc_name   = optional(string, "improve-app-availability-vpc")
    cidr_block = string
  })
}

variable "ecs_vswitches_config" {
  description = "List of VSwitch configurations for ECS instances. Each VSwitch requires 'cidr_block' and 'zone_id'. Note: 'cidr_block' and 'zone_id' cannot be changed after creation."
  type = list(object({
    cidr_block   = string
    zone_id      = string
    vswitch_name = optional(string, "improve-app-availability-ecs-vsw")
  }))
}

variable "alb_vswitches_config" {
  description = "List of VSwitch configurations for ALB. Each VSwitch requires 'cidr_block' and 'zone_id'. Note: 'cidr_block' and 'zone_id' cannot be changed after creation."
  type = list(object({
    cidr_block   = string
    zone_id      = string
    vswitch_name = optional(string, "improve-app-availability-alb-vsw")
  }))
}

variable "security_group_config" {
  description = "Configuration for security group. The 'security_group_name' attribute has a default value."
  type = object({
    security_group_name = optional(string, "improve-app-availability-sg")
    description         = optional(string, "Security group for improve app availability")
  })
  default = {}
}

variable "security_group_rules_config" {
  description = "List of security group rule configurations. Default allows HTTP (80) and HTTPS (443) traffic from VPC CIDR."
  type = list(object({
    type        = string
    ip_protocol = string
    port_range  = string
    cidr_ip     = string
    policy      = optional(string, "accept")
    priority    = optional(number, 1)
  }))
  default = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "0.0.0.0/0"
    },
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "443/443"
      cidr_ip     = "0.0.0.0/0"
    }
  ]
}

variable "alb_config" {
  description = "Configuration for ALB load balancer. The 'load_balancer_name' attribute has a default value."
  type = object({
    load_balancer_name     = optional(string, "improve-app-availability-alb")
    load_balancer_edition  = optional(string, "Basic")
    address_allocated_mode = optional(string, "Fixed")
    address_type           = optional(string, "Internet")
    pay_type               = optional(string, "PayAsYouGo")
  })
  default = {}
}


variable "alb_server_group_config" {
  description = "Configuration for ALB server group. The 'server_group_name' attribute has a default value."
  type = object({
    server_group_name         = optional(string, "improve-app-availability-server-group")
    protocol                  = optional(string, "HTTP")
    health_check_enabled      = optional(bool, true)
    health_check_protocol     = optional(string, "HTTP")
    health_check_path         = optional(string, "/")
    health_check_codes        = optional(list(string), ["http_2xx", "http_3xx"])
    health_check_connect_port = optional(number, 80)
    sticky_session_enabled    = optional(bool, false)
  })
  default = {}
}

variable "alb_listener_config" {
  description = "Configuration for ALB listener. The 'listener_protocol' and 'listener_port' attributes have default values."
  type = object({
    listener_protocol   = optional(string, "HTTP")
    listener_port       = optional(number, 80)
    default_action_type = optional(string, "ForwardGroup")
  })
  default = {}
}

variable "ess_scaling_group_config" {
  description = "Configuration for ESS scaling group. The 'scaling_group_name', 'min_size', and 'max_size' attributes have default values."
  type = object({
    scaling_group_name = optional(string, "improve-app-availability-scaling-group")
    min_size           = optional(number, 1)
    max_size           = optional(number, 3)
    removal_policies   = optional(list(string), ["NewestInstance"])
    default_cooldown   = optional(number, 300)
    multi_az_policy    = optional(string, "COMPOSABLE")
    az_balance         = optional(bool, true)
  })
  default = {}
}

variable "ess_server_group_attachment_config" {
  description = "Configuration for ESS server group attachment. The 'port' attribute has a default value of 80."
  type = object({
    port         = optional(number, 80)
    type         = optional(string, "ALB")
    weight       = optional(number, 100)
    force_attach = optional(bool, true)
  })
  default = {}
}

variable "ess_scaling_configuration_config" {
  description = "Configuration for ESS scaling configuration. The 'image_id', 'instance_types', and 'password' attributes are required."
  type = object({
    enable               = optional(bool, true)
    active               = optional(bool, true)
    force_delete         = optional(bool, true)
    image_id             = string
    instance_types       = list(string)
    system_disk_category = optional(string, "cloud_essd")
    system_disk_size     = optional(number, 40)
    password             = string
    instance_name        = optional(string, "improve-app-availability-ess")
  })
}

variable "ess_scaling_rules_config" {
  description = "List of ESS scaling rule configurations. Default includes scale-up and scale-down rules."
  type = list(object({
    scaling_rule_name = string
    scaling_rule_type = optional(string, "SimpleScalingRule")
    adjustment_type   = string
    adjustment_value  = number
    cooldown          = optional(number, 60)
  }))
  default = [
    {
      scaling_rule_name = "improve-app-availability-scale-up"
      adjustment_type   = "QuantityChangeInCapacity"
      adjustment_value  = 1
    },
    {
      scaling_rule_name = "improve-app-availability-scale-down"
      adjustment_type   = "QuantityChangeInCapacity"
      adjustment_value  = -1
    }
  ]
}

variable "ess_scheduled_tasks_config" {
  description = "List of ESS scheduled task configurations. Each task requires 'scheduled_task_name', 'launch_time', and 'scaling_rule_name'."
  type = list(object({
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