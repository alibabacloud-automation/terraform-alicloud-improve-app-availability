Alibaba Cloud Improve App Availability Terraform Module

# terraform-alicloud-improve-app-availability

English | [简体中文](https://github.com/alibabacloud-automation/terraform-alicloud-improve-app-availability/blob/main/README-CN.md)

This Terraform module implements the [Auto Scaling and Stable Delivery](https://www.aliyun.com/solution/tech-solution/improve-app-availability) solution on Alibaba Cloud. The module creates a complete high-availability infrastructure including Virtual Private Cloud (VPC), VSwitches, Elastic Compute Service (ECS), Application Load Balancer (ALB), and Elastic Scaling Service (ESS) resources to ensure your applications can automatically scale and maintain stable delivery under varying loads.

## Usage

This module helps you quickly set up an auto-scaling web application infrastructure with load balancing and high availability features. The infrastructure automatically adjusts the number of ECS instances based on demand and distributes traffic through ALB for optimal performance.

```terraform
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

module "improve_app_availability" {
  source = "alibabacloud-automation/improve-app-availability/alicloud"

  vpc_config = {
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

  ess_scheduled_tasks_config = [
    {
      name                = "scale_up_task"
      scheduled_task_name = "${var.common_name}-scale_up_task-${random_integer.default.result}"
      launch_time         = formatdate("YYYY-MM-DD'T'HH:mm'Z'", timeadd(time_static.example.rfc3339, "1h"))
      scaling_rule_name   = "scale_up"
    },
    {
      name                = "scale_down_task"
      scheduled_task_name = "${var.common_name}-scale_down_task-${random_integer.default.result}"
      launch_time         = formatdate("YYYY-MM-DD'T'HH:mm'Z'", timeadd(time_static.example.rfc3339, "2h"))
      scaling_rule_name   = "scale_down"
    }
  ]
}
```

## Examples

* [Complete Example](https://github.com/alibabacloud-automation/terraform-alicloud-improve-app-availability/tree/main/examples/complete)


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.131.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | >= 1.131.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_alb_listener.alb_listener](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_listener) | resource |
| [alicloud_alb_load_balancer.alb](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_load_balancer) | resource |
| [alicloud_alb_server_group.alb_server_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_server_group) | resource |
| [alicloud_ess_scaling_configuration.ess_scaling_configuration](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ess_scaling_configuration) | resource |
| [alicloud_ess_scaling_group.ess_scaling_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ess_scaling_group) | resource |
| [alicloud_ess_scaling_rule.ess_scaling_rules](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ess_scaling_rule) | resource |
| [alicloud_ess_scheduled_task.ess_scheduled_tasks](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ess_scheduled_task) | resource |
| [alicloud_ess_server_group_attachment.ess_server_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ess_server_group_attachment) | resource |
| [alicloud_security_group.security_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_security_group_rule.security_group_rules](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource |
| [alicloud_vpc.vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vswitch.alb_vswitches](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |
| [alicloud_vswitch.ecs_vswitches](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_config"></a> [alb\_config](#input\_alb\_config) | Configuration for ALB load balancer. The 'load\_balancer\_name' attribute is required. | <pre>object({<br/>    load_balancer_name     = string<br/>    load_balancer_edition  = optional(string, "Basic")<br/>    address_allocated_mode = optional(string, "Fixed")<br/>    address_type           = optional(string, "Internet")<br/>    pay_type               = optional(string, "PayAsYouGo")<br/>  })</pre> | n/a | yes |
| <a name="input_alb_listener_config"></a> [alb\_listener\_config](#input\_alb\_listener\_config) | Configuration for ALB listener. The 'listener\_protocol' and 'listener\_port' attributes are required. | <pre>object({<br/>    listener_protocol   = string<br/>    listener_port       = number<br/>    default_action_type = optional(string, "ForwardGroup")<br/>  })</pre> | n/a | yes |
| <a name="input_alb_server_group_config"></a> [alb\_server\_group\_config](#input\_alb\_server\_group\_config) | Configuration for ALB server group. The 'server\_group\_name' attribute is required. | <pre>object({<br/>    server_group_name         = string<br/>    protocol                  = optional(string, "HTTP")<br/>    health_check_enabled      = optional(bool, true)<br/>    health_check_protocol     = optional(string, "HTTP")<br/>    health_check_path         = optional(string, "/")<br/>    health_check_codes        = optional(list(string), ["http_2xx", "http_3xx"])<br/>    health_check_connect_port = optional(number, 80)<br/>    sticky_session_enabled    = optional(bool, false)<br/>  })</pre> | n/a | yes |
| <a name="input_alb_vswitches_config"></a> [alb\_vswitches\_config](#input\_alb\_vswitches\_config) | List of VSwitch configurations for ALB. Each VSwitch requires 'name', 'cidr\_block', 'zone\_id', and 'vswitch\_name'. Note: 'cidr\_block' and 'zone\_id' cannot be changed after creation. | <pre>list(object({<br/>    name         = string<br/>    cidr_block   = string<br/>    zone_id      = string<br/>    vswitch_name = string<br/>  }))</pre> | n/a | yes |
| <a name="input_custom_user_data_script"></a> [custom\_user\_data\_script](#input\_custom\_user\_data\_script) | Custom user data script for ECS instance initialization. If not provided, the default script will be used. | `string` | `null` | no |
| <a name="input_ecs_vswitches_config"></a> [ecs\_vswitches\_config](#input\_ecs\_vswitches\_config) | List of VSwitch configurations for ECS instances. Each VSwitch requires 'name', 'cidr\_block', 'zone\_id', and 'vswitch\_name'. Note: 'cidr\_block' and 'zone\_id' cannot be changed after creation. | <pre>list(object({<br/>    name         = string<br/>    cidr_block   = string<br/>    zone_id      = string<br/>    vswitch_name = string<br/>  }))</pre> | n/a | yes |
| <a name="input_ess_scaling_configuration_config"></a> [ess\_scaling\_configuration\_config](#input\_ess\_scaling\_configuration\_config) | Configuration for ESS scaling configuration. The 'image\_id', 'instance\_types', 'password', and 'instance\_name' attributes are required. | <pre>object({<br/>    enable               = optional(bool, true)<br/>    active               = optional(bool, true)<br/>    force_delete         = optional(bool, true)<br/>    image_id             = string<br/>    instance_types       = list(string)<br/>    system_disk_category = optional(string, "cloud_essd")<br/>    system_disk_size     = optional(number, 40)<br/>    password             = string<br/>    instance_name        = string<br/>  })</pre> | n/a | yes |
| <a name="input_ess_scaling_group_config"></a> [ess\_scaling\_group\_config](#input\_ess\_scaling\_group\_config) | Configuration for ESS scaling group. The 'scaling\_group\_name', 'min\_size', and 'max\_size' attributes are required. | <pre>object({<br/>    scaling_group_name = string<br/>    min_size           = number<br/>    max_size           = number<br/>    removal_policies   = optional(list(string), ["NewestInstance"])<br/>    default_cooldown   = optional(number, 300)<br/>    multi_az_policy    = optional(string, "COMPOSABLE")<br/>    az_balance         = optional(bool, true)<br/>  })</pre> | n/a | yes |
| <a name="input_ess_scaling_rules_config"></a> [ess\_scaling\_rules\_config](#input\_ess\_scaling\_rules\_config) | List of ESS scaling rule configurations. Each rule requires 'name', 'scaling\_rule\_name', 'scaling\_rule\_type', 'adjustment\_type', 'adjustment\_value', and 'cooldown'. | <pre>list(object({<br/>    name              = string<br/>    scaling_rule_name = string<br/>    scaling_rule_type = optional(string, "SimpleScalingRule")<br/>    adjustment_type   = string<br/>    adjustment_value  = number<br/>    cooldown          = optional(number, 60)<br/>  }))</pre> | `[]` | no |
| <a name="input_ess_scheduled_tasks_config"></a> [ess\_scheduled\_tasks\_config](#input\_ess\_scheduled\_tasks\_config) | List of ESS scheduled task configurations. Each task requires 'name', 'scheduled\_task\_name', 'launch\_time', 'scaling\_rule\_name', and 'launch\_expiration\_time'. | <pre>list(object({<br/>    name                   = string<br/>    scheduled_task_name    = string<br/>    launch_time            = string<br/>    scaling_rule_name      = string<br/>    launch_expiration_time = optional(number, 10)<br/>  }))</pre> | `[]` | no |
| <a name="input_ess_server_group_attachment_config"></a> [ess\_server\_group\_attachment\_config](#input\_ess\_server\_group\_attachment\_config) | Configuration for ESS server group attachment. The 'port' attribute is required. | <pre>object({<br/>    port         = number<br/>    type         = optional(string, "ALB")<br/>    weight       = optional(number, 100)<br/>    force_attach = optional(bool, true)<br/>  })</pre> | n/a | yes |
| <a name="input_security_group_config"></a> [security\_group\_config](#input\_security\_group\_config) | Configuration for security group. The 'security\_group\_name' attribute is required. | <pre>object({<br/>    security_group_name = string<br/>    description         = optional(string, "Security group for improve app availability")<br/>  })</pre> | n/a | yes |
| <a name="input_security_group_rules_config"></a> [security\_group\_rules\_config](#input\_security\_group\_rules\_config) | List of security group rule configurations. Each rule requires 'type', 'ip\_protocol', 'port\_range', and 'cidr\_ip'. | <pre>list(object({<br/>    type        = string<br/>    ip_protocol = string<br/>    port_range  = string<br/>    cidr_ip     = string<br/>    policy      = optional(string, "accept")<br/>    priority    = optional(number, 1)<br/>  }))</pre> | `[]` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | Configuration for VPC. The 'cidr\_block' attribute is required and cannot be changed after creation. | <pre>object({<br/>    vpc_name   = optional(string, "improve-app-availability-vpc")<br/>    cidr_block = string<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | The DNS name of the ALB load balancer |
| <a name="output_alb_id"></a> [alb\_id](#output\_alb\_id) | The ID of the ALB load balancer |
| <a name="output_alb_listener_id"></a> [alb\_listener\_id](#output\_alb\_listener\_id) | The ID of the ALB listener |
| <a name="output_alb_server_group_id"></a> [alb\_server\_group\_id](#output\_alb\_server\_group\_id) | The ID of the ALB server group |
| <a name="output_alb_vswitch_ids"></a> [alb\_vswitch\_ids](#output\_alb\_vswitch\_ids) | Map of ALB VSwitch names to their IDs |
| <a name="output_ecs_vswitch_ids"></a> [ecs\_vswitch\_ids](#output\_ecs\_vswitch\_ids) | Map of ECS VSwitch names to their IDs |
| <a name="output_ess_scaling_configuration_id"></a> [ess\_scaling\_configuration\_id](#output\_ess\_scaling\_configuration\_id) | The ID of the ESS scaling configuration |
| <a name="output_ess_scaling_group_id"></a> [ess\_scaling\_group\_id](#output\_ess\_scaling\_group\_id) | The ID of the ESS scaling group |
| <a name="output_ess_scaling_rule_aris"></a> [ess\_scaling\_rule\_aris](#output\_ess\_scaling\_rule\_aris) | Map of ESS scaling rule names to their ARIs |
| <a name="output_ess_scaling_rule_ids"></a> [ess\_scaling\_rule\_ids](#output\_ess\_scaling\_rule\_ids) | Map of ESS scaling rule names to their IDs |
| <a name="output_ess_scheduled_task_ids"></a> [ess\_scheduled\_task\_ids](#output\_ess\_scheduled\_task\_ids) | Map of ESS scheduled task names to their IDs |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_web_url"></a> [web\_url](#output\_web\_url) | The web access URL of the application |
<!-- END_TF_DOCS -->

## Submit Issues

If you have any problems when using this module, please opening
a [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) and let us know.

**Note:** There does not recommend opening an issue on this repo.

## Authors

Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com).

## License

MIT Licensed. See LICENSE for full details.

## Reference

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)