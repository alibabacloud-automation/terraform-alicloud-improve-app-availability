Alibaba Cloud Improve App Availability Terraform Module

================================================ 

# terraform-alicloud-improve-app-availability

English | [简体中文](https://github.com/alibabacloud-automation/terraform-alicloud-improve-app-availability/blob/main/README-CN.md)

This Terraform module implements the [Auto Scaling and Stable Delivery](https://www.aliyun.com/solution/tech-solution/improve-app-availability) solution on Alibaba Cloud. The module creates a complete high-availability infrastructure including Virtual Private Cloud (VPC), VSwitches, Elastic Compute Service (ECS), Application Load Balancer (ALB), and Elastic Scaling Service (ESS) resources to ensure your applications can automatically scale and maintain stable delivery under varying loads.

## Usage

This module helps you quickly set up an auto-scaling web application infrastructure with load balancing and high availability features. The infrastructure automatically adjusts the number of ECS instances based on demand and distributes traffic through ALB for optimal performance.

```terraform
data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

data "alicloud_alb_zones" "default" {}

data "alicloud_instance_types" "default" {
  availability_zone = data.alicloud_zones.default.zones[0].id
  instance_type_family = "ecs.g7"
}

data "alicloud_images" "default" {
  name_regex  = "^aliyun_3_9_x64_20G_*"
  most_recent = true
  owners      = "system"
}

module "improve_app_availability" {
  source  = "alibabacloud-automation/improve-app-availability/alicloud"

  vpc_config = {
    vpc_name   = "my-app-vpc"
    cidr_block = "192.168.0.0/16"
  }

  vswitches_config = [
    {
      name         = "ecs_vswitch_1"
      cidr_block   = "192.168.1.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "my-app-ecs-vsw-1"
    },
    {
      name         = "alb_vswitch_1"
      cidr_block   = "192.168.3.0/24"
      zone_id      = data.alicloud_alb_zones.default.zones[0].id
      vswitch_name = "my-app-alb-vsw-1"
    }
  ]

  security_group_config = {
    security_group_name = "my-app-sg"
  }

  security_group_rules_config = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "0.0.0.0/0"
    }
  ]

  alb_config = {
    load_balancer_name = "my-app-alb"
  }

  alb_server_group_config = {
    server_group_name = "my-app-server-group"
  }

  alb_listener_config = {
    listener_protocol = "HTTP"
    listener_port     = 80
  }

  ess_scaling_group_config = {
    scaling_group_name = "my-app"
    min_size           = 2
    max_size           = 5
    vswitch_names      = ["ecs_vswitch_1"]
  }

  ess_scaling_configuration_config = {
    image_id      = data.alicloud_images.default.images[0].id
    instance_types = [data.alicloud_instance_types.default.instance_types[0].id]
    password      = "YourPassword123!"
    instance_name = "my-app-ess"
  }
}
```

## Examples

* [Complete Example](https://github.com/alibabacloud-automation/terraform-alicloud-improve-app-availability/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
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