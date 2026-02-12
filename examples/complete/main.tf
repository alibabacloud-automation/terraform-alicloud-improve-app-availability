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

# Time static resource for scheduling
resource "time_static" "example" {}

# Random integer for unique task names
resource "random_integer" "default" {
  min = 1
  max = 99999
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
      cidr_block   = "192.168.1.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "${var.common_name}-ecs-vsw-1"
    },
    {
      cidr_block   = "192.168.2.0/24"
      zone_id      = data.alicloud_zones.default.zones[1].id
      vswitch_name = "${var.common_name}-ecs-vsw-2"
    }
  ]

  alb_vswitches_config = [
    {
      cidr_block   = "192.168.3.0/24"
      zone_id      = data.alicloud_alb_zones.default.zones[0].id
      vswitch_name = "${var.common_name}-alb-vsw-1"
    },
    {
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
      scaling_rule_name = "${var.common_name}-scale-up"
      adjustment_type   = "QuantityChangeInCapacity"
      adjustment_value  = 1
    },
    {
      scaling_rule_name = "${var.common_name}-scale-down"
      adjustment_type   = "QuantityChangeInCapacity"
      adjustment_value  = -1
    }
  ]

  ess_scheduled_tasks_config = [
    {
      scheduled_task_name    = "${var.common_name}-scale_up_task"
      launch_time            = format("%sZ", substr(timeadd(time_static.example.rfc3339, "11h"), 0, 16))
      scaling_rule_name      = "${var.common_name}-scale-up"
      launch_expiration_time = 10
    },
    {
      scheduled_task_name    = "${var.common_name}-scale_down_task"
      launch_time            = format("%sZ", substr(timeadd(time_static.example.rfc3339, "12h"), 0, 16))
      scaling_rule_name      = "${var.common_name}-scale-down"
      launch_expiration_time = 10
    }
  ]
}