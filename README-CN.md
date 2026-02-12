阿里云提升应用可用性 Terraform 模块

# terraform-alicloud-improve-app-availability

[English](https://github.com/alibabacloud-automation/terraform-alicloud-improve-app-availability/blob/main/README.md) | 简体中文

本 Terraform 模块实现了阿里云上的[自动弹性，稳定交付](https://www.aliyun.com/solution/tech-solution/improve-app-availability)解决方案。该模块创建了完整的高可用基础设施，包括专有网络（VPC）、交换机（VSwitch）、云服务器（ECS）、应用型负载均衡器（ALB）和弹性伸缩（ESS）资源，确保您的应用程序能够自动扩缩容并在不同负载下保持稳定交付。

## 使用方法

此模块帮助您快速建立具有负载均衡和高可用性功能的自动扩缩容 Web 应用程序基础设施。该基础设施根据需求自动调整 ECS 实例数量，并通过 ALB 分发流量以实现最佳性能。

```terraform
provider "alicloud" {
  region = "ap-southeast-5"
}

data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

data "alicloud_alb_zones" "default" {}

data "alicloud_images" "default" {
  name_regex  = "^aliyun_3_9_x64_20G_*"
  most_recent = true
  owners      = "system"
}

resource "random_password" "ecs_password" {
  length  = 16
  special = true
}

module "improve_app_availability" {
  source = "alibabacloud-automation/improve-app-availability/alicloud"

  vpc_config = {
    cidr_block = "192.168.0.0/16"
  }

  ecs_vswitches_config = [
    {
      cidr_block = "192.168.1.0/24"
      zone_id    = data.alicloud_zones.default.zones[0].id
    },
    {
      cidr_block = "192.168.2.0/24"
      zone_id    = data.alicloud_zones.default.zones[1].id
    }
  ]

  alb_vswitches_config = [
    {
      cidr_block = "192.168.3.0/24"
      zone_id    = data.alicloud_alb_zones.default.zones[0].id
    },
    {
      cidr_block = "192.168.4.0/24"
      zone_id    = data.alicloud_alb_zones.default.zones[1].id
    }
  ]

  ess_scaling_configuration_config = {
    image_id       = data.alicloud_images.default.images[0].id
    instance_types = ["ecs.g7.large"]
    password       = random_password.ecs_password.result
  }
}
```

## 示例

* [完整示例](https://github.com/alibabacloud-automation/terraform-alicloud-improve-app-availability/tree/main/examples/complete)

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
| <a name="input_alb_config"></a> [alb\_config](#input\_alb\_config) | Configuration for ALB load balancer. The 'load\_balancer\_name' attribute has a default value. | <pre>object({<br/>    load_balancer_name     = optional(string, "improve-app-availability-alb")<br/>    load_balancer_edition  = optional(string, "Basic")<br/>    address_allocated_mode = optional(string, "Fixed")<br/>    address_type           = optional(string, "Internet")<br/>    pay_type               = optional(string, "PayAsYouGo")<br/>  })</pre> | `{}` | no |
| <a name="input_alb_listener_config"></a> [alb\_listener\_config](#input\_alb\_listener\_config) | Configuration for ALB listener. The 'listener\_protocol' and 'listener\_port' attributes have default values. | <pre>object({<br/>    listener_protocol   = optional(string, "HTTP")<br/>    listener_port       = optional(number, 80)<br/>    default_action_type = optional(string, "ForwardGroup")<br/>  })</pre> | `{}` | no |
| <a name="input_alb_server_group_config"></a> [alb\_server\_group\_config](#input\_alb\_server\_group\_config) | Configuration for ALB server group. The 'server\_group\_name' attribute has a default value. | <pre>object({<br/>    server_group_name         = optional(string, "improve-app-availability-server-group")<br/>    protocol                  = optional(string, "HTTP")<br/>    health_check_enabled      = optional(bool, true)<br/>    health_check_protocol     = optional(string, "HTTP")<br/>    health_check_path         = optional(string, "/")<br/>    health_check_codes        = optional(list(string), ["http_2xx", "http_3xx"])<br/>    health_check_connect_port = optional(number, 80)<br/>    sticky_session_enabled    = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_alb_vswitches_config"></a> [alb\_vswitches\_config](#input\_alb\_vswitches\_config) | List of VSwitch configurations for ALB. Each VSwitch requires 'cidr\_block' and 'zone\_id'. Note: 'cidr\_block' and 'zone\_id' cannot be changed after creation. | <pre>list(object({<br/>    cidr_block   = string<br/>    zone_id      = string<br/>    vswitch_name = optional(string, "improve-app-availability-alb-vsw")<br/>  }))</pre> | n/a | yes |
| <a name="input_custom_user_data_script"></a> [custom\_user\_data\_script](#input\_custom\_user\_data\_script) | Custom user data script for ECS instance initialization. If not provided, the default script will be used. | `string` | `null` | no |
| <a name="input_ecs_vswitches_config"></a> [ecs\_vswitches\_config](#input\_ecs\_vswitches\_config) | List of VSwitch configurations for ECS instances. Each VSwitch requires 'cidr\_block' and 'zone\_id'. Note: 'cidr\_block' and 'zone\_id' cannot be changed after creation. | <pre>list(object({<br/>    cidr_block   = string<br/>    zone_id      = string<br/>    vswitch_name = optional(string, "improve-app-availability-ecs-vsw")<br/>  }))</pre> | n/a | yes |
| <a name="input_ess_scaling_configuration_config"></a> [ess\_scaling\_configuration\_config](#input\_ess\_scaling\_configuration\_config) | Configuration for ESS scaling configuration. The 'image\_id', 'instance\_types', and 'password' attributes are required. | <pre>object({<br/>    enable               = optional(bool, true)<br/>    active               = optional(bool, true)<br/>    force_delete         = optional(bool, true)<br/>    image_id             = string<br/>    instance_types       = list(string)<br/>    system_disk_category = optional(string, "cloud_essd")<br/>    system_disk_size     = optional(number, 40)<br/>    password             = string<br/>    instance_name        = optional(string, "improve-app-availability-ess")<br/>  })</pre> | n/a | yes |
| <a name="input_ess_scaling_group_config"></a> [ess\_scaling\_group\_config](#input\_ess\_scaling\_group\_config) | Configuration for ESS scaling group. The 'scaling\_group\_name', 'min\_size', and 'max\_size' attributes have default values. | <pre>object({<br/>    scaling_group_name = optional(string, "improve-app-availability-scaling-group")<br/>    min_size           = optional(number, 1)<br/>    max_size           = optional(number, 3)<br/>    removal_policies   = optional(list(string), ["NewestInstance"])<br/>    default_cooldown   = optional(number, 300)<br/>    multi_az_policy    = optional(string, "COMPOSABLE")<br/>    az_balance         = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_ess_scaling_rules_config"></a> [ess\_scaling\_rules\_config](#input\_ess\_scaling\_rules\_config) | List of ESS scaling rule configurations. Default includes scale-up and scale-down rules. | <pre>list(object({<br/>    scaling_rule_name = string<br/>    scaling_rule_type = optional(string, "SimpleScalingRule")<br/>    adjustment_type   = string<br/>    adjustment_value  = number<br/>    cooldown          = optional(number, 60)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "adjustment_type": "QuantityChangeInCapacity",<br/>    "adjustment_value": 1,<br/>    "scaling_rule_name": "improve-app-availability-scale-up"<br/>  },<br/>  {<br/>    "adjustment_type": "QuantityChangeInCapacity",<br/>    "adjustment_value": -1,<br/>    "scaling_rule_name": "improve-app-availability-scale-down"<br/>  }<br/>]</pre> | no |
| <a name="input_ess_scheduled_tasks_config"></a> [ess\_scheduled\_tasks\_config](#input\_ess\_scheduled\_tasks\_config) | List of ESS scheduled task configurations. Each task requires 'scheduled\_task\_name', 'launch\_time', and 'scaling\_rule\_name'. | <pre>list(object({<br/>    scheduled_task_name    = string<br/>    launch_time            = string<br/>    scaling_rule_name      = string<br/>    launch_expiration_time = optional(number, 10)<br/>  }))</pre> | `[]` | no |
| <a name="input_ess_server_group_attachment_config"></a> [ess\_server\_group\_attachment\_config](#input\_ess\_server\_group\_attachment\_config) | Configuration for ESS server group attachment. The 'port' attribute has a default value of 80. | <pre>object({<br/>    port         = optional(number, 80)<br/>    type         = optional(string, "ALB")<br/>    weight       = optional(number, 100)<br/>    force_attach = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_security_group_config"></a> [security\_group\_config](#input\_security\_group\_config) | Configuration for security group. The 'security\_group\_name' attribute has a default value. | <pre>object({<br/>    security_group_name = optional(string, "improve-app-availability-sg")<br/>    description         = optional(string, "Security group for improve app availability")<br/>  })</pre> | `{}` | no |
| <a name="input_security_group_rules_config"></a> [security\_group\_rules\_config](#input\_security\_group\_rules\_config) | List of security group rule configurations. Default allows HTTP (80) and HTTPS (443) traffic from VPC CIDR. | <pre>list(object({<br/>    type        = string<br/>    ip_protocol = string<br/>    port_range  = string<br/>    cidr_ip     = string<br/>    policy      = optional(string, "accept")<br/>    priority    = optional(number, 1)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_ip": "0.0.0.0/0",<br/>    "ip_protocol": "tcp",<br/>    "port_range": "80/80",<br/>    "type": "ingress"<br/>  },<br/>  {<br/>    "cidr_ip": "0.0.0.0/0",<br/>    "ip_protocol": "tcp",<br/>    "port_range": "443/443",<br/>    "type": "ingress"<br/>  }<br/>]</pre> | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | Configuration for VPC. The 'cidr\_block' attribute is required and cannot be changed after creation. | <pre>object({<br/>    vpc_name   = optional(string, "improve-app-availability-vpc")<br/>    cidr_block = string<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | The DNS name of the ALB load balancer |
| <a name="output_alb_id"></a> [alb\_id](#output\_alb\_id) | The ID of the ALB load balancer |
| <a name="output_alb_listener_id"></a> [alb\_listener\_id](#output\_alb\_listener\_id) | The ID of the ALB listener |
| <a name="output_alb_server_group_id"></a> [alb\_server\_group\_id](#output\_alb\_server\_group\_id) | The ID of the ALB server group |
| <a name="output_alb_vswitch_ids"></a> [alb\_vswitch\_ids](#output\_alb\_vswitch\_ids) | Map of ALB VSwitch indices to their IDs |
| <a name="output_ecs_vswitch_ids"></a> [ecs\_vswitch\_ids](#output\_ecs\_vswitch\_ids) | Map of ECS VSwitch indices to their IDs |
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

## 提交问题

如果您在使用此模块时遇到任何问题，请提交一个 [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) 并告知我们。

**注意：** 不建议在此仓库中提交问题。

## 作者

由阿里云 Terraform 团队创建和维护(terraform@alibabacloud.com)。

## 许可证

MIT 许可。有关完整详细信息，请参阅 LICENSE。

## 参考

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)