provider "alicloud" {
  region = "ap-southeast-5"
}

# Data sources for getting available zones and instance types
data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

data "alicloud_alb_zones" "default" {}

data "alicloud_instance_types" "default" {
  availability_zone    = data.alicloud_zones.default.zones[0].id
  instance_type_family = "ecs.g7"
}

data "alicloud_images" "default" {
  name_regex  = "^aliyun_3_9_x64_20G_*"
  most_recent = true
  owners      = "system"
}

# Generate a random password for ECS instances
resource "random_password" "ecs_password" {
  length  = 16
  special = true
}

# Call the improve-app-availability module
module "improve_app_availability" {
  source = "../../"

  vpc_config = {
    vpc_name   = var.common_name
    cidr_block = "192.168.0.0/16"
  }

  ecs_vswitches_config = [
    {
      name         = "ecs_vswitch_1"
      cidr_block   = "192.168.1.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "${var.common_name}-ecs-vsw-1"
    },
    {
      name         = "ecs_vswitch_2"
      cidr_block   = "192.168.2.0/24"
      zone_id      = data.alicloud_zones.default.zones[1].id
      vswitch_name = "${var.common_name}-ecs-vsw-1"
    }
  ]

  alb_vswitches_config = [
    {
      name         = "alb_vswitch_1"
      cidr_block   = "192.168.3.0/24"
      zone_id      = data.alicloud_alb_zones.default.zones[0].id
      vswitch_name = "${var.common_name}-alb-vsw-1"
    },
    {
      name         = "alb_vswitch_2"
      cidr_block   = "192.168.4.0/24"
      zone_id      = data.alicloud_alb_zones.default.zones[1].id
      vswitch_name = "${var.common_name}-alb-vsw-2"
    }
  ]

  security_group_config = {
    security_group_name = "${var.common_name}-sg"
  }

  security_group_rules_config = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "192.168.0.0/16"
    },
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "443/443"
      cidr_ip     = "192.168.0.0/16"
    }
  ]

  alb_config = {
    load_balancer_name = "${var.common_name}-alb"
  }

  alb_server_group_config = {
    server_group_name = "${var.common_name}-server-group"
  }

  alb_listener_config = {
    listener_protocol = "HTTP"
    listener_port     = 80
  }

  ess_scaling_group_config = {
    scaling_group_name = var.common_name
    min_size           = 1
    max_size           = 3
  }

  ess_server_group_attachment_config = {
    port = 80
  }

  ess_scaling_configuration_config = {
    image_id       = data.alicloud_images.default.images[0].id
    instance_types = length(data.alicloud_instance_types.default.instance_types) > 0 ? [data.alicloud_instance_types.default.instance_types[0].id] : ["ecs.g7.large"]
    password       = random_password.ecs_password.result
    instance_name  = "${var.common_name}-ess"
  }

  ess_scaling_rules_config = [
    {
      name              = "scale_up"
      scaling_rule_name = "${var.common_name}-scale-up"
      adjustment_type   = "QuantityChangeInCapacity"
      adjustment_value  = 1
    },
    {
      name              = "scale_down"
      scaling_rule_name = "${var.common_name}-scale-down"
      adjustment_type   = "QuantityChangeInCapacity"
      adjustment_value  = -1
    }
  ]

  ess_scheduled_tasks_config = var.scale_up_time != null || var.scale_down_time != null ? [
    {
      name                = "scale_up_task"
      scheduled_task_name = "${var.common_name}-scale-up-task"
      launch_time         = var.scale_up_time != null && var.scale_up_time != "" ? var.scale_up_time : formatdate("YYYY-MM-DD'T'HH:mm'Z'", timeadd(timestamp(), "1h"))
      scaling_rule_name   = "scale_up"
    },
    {
      name                = "scale_down_task"
      scheduled_task_name = "${var.common_name}-scale-down-task"
      launch_time         = var.scale_down_time != null && var.scale_down_time != "" ? var.scale_down_time : formatdate("YYYY-MM-DD'T'HH:mm'Z'", timeadd(timestamp(), "2h"))
      scaling_rule_name   = "scale_down"
    }
  ] : []
}